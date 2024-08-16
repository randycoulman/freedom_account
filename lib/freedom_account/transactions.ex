defmodule FreedomAccount.Transactions do
  @moduledoc """
  Context for working with transactions in a Freedom Account.
  """
  use Boundary,
    deps: [
      FreedomAccount.Accounts,
      FreedomAccount.Error,
      FreedomAccount.ErrorReporter,
      FreedomAccount.Funds,
      FreedomAccount.Loans,
      FreedomAccount.MoneyUtils,
      FreedomAccount.Paging,
      FreedomAccount.PubSub,
      FreedomAccount.Repo
    ],
    exports: [LoanTransaction, Transaction]

  import Ecto.Query, only: [from: 1, subquery: 1]

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error
  alias FreedomAccount.Error.InvariantError
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Error.ServiceError
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.Paging
  alias FreedomAccount.PubSub
  alias FreedomAccount.Repo
  alias FreedomAccount.Transactions.DateCache
  alias FreedomAccount.Transactions.FundTransaction
  alias FreedomAccount.Transactions.LineItem
  alias FreedomAccount.Transactions.LoanTransaction
  alias FreedomAccount.Transactions.Transaction
  alias Paginator.Page

  require Ecto.Query
  require FreedomAccount.ErrorReporter, as: ErrorReporter

  @opaque cursor :: Paging.cursor()
  @type list_opt :: {:next_cursor, cursor()} | {:per_page, pos_integer()} | {:prev_cursor, cursor()}

  @spec change_loan_transaction(LoanTransaction.t(), LoanTransaction.attrs()) :: Changeset.t()
  def change_loan_transaction(%LoanTransaction{} = transaction, attrs \\ %{}) do
    LoanTransaction.changeset(transaction, attrs)
  end

  @spec change_transaction(Transaction.t(), Transaction.attrs()) :: Changeset.t()
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  @spec delete_loan_transaction(LoanTransaction.t()) :: :ok | {:error, ServiceError.t()}
  def delete_loan_transaction(%LoanTransaction{} = transaction) do
    transaction
    |> Repo.delete()
    |> PubSub.broadcast(pubsub_topic(), :loan_transaction_deleted)
    |> case do
      {:ok, _transaction} ->
        :ok

      {:error, %Changeset{} = changeset} ->
        ErrorReporter.call("Failed to delete a loan transaction",
          error: inspect(changeset),
          metadata: %{transaction_id: transaction.id}
        )

        {:error, Error.service(message: "Failed to delete a transaction", service: :database)}
    end
  end

  @spec delete_transaction(Transaction.t()) :: :ok | {:error, ServiceError.t()}
  def delete_transaction(%Transaction{} = transaction) do
    transaction
    |> Repo.delete()
    |> PubSub.broadcast(pubsub_topic(), :transaction_deleted)
    |> case do
      {:ok, _transaction} ->
        :ok

      {:error, %Changeset{} = changeset} ->
        ErrorReporter.call("Failed to delete a transaction",
          error: inspect(changeset),
          metadata: %{transaction_id: transaction.id}
        )

        {:error, Error.service(message: "Failed to delete a transaction", service: :database)}
    end
  end

  @spec deposit(Account.t(), Transaction.attrs()) :: {:ok, Transaction.t()} | {:error, Changeset.t()}
  def deposit(%Account{} = account, attrs \\ %{}) do
    %Transaction{}
    |> Transaction.deposit_changeset(attrs)
    |> Repo.insert()
    |> cache_date(account)
    |> PubSub.broadcast(pubsub_topic(), :transaction_created)
  end

  @spec fetch_loan_transaction(LoanTransaction.id()) :: {:ok, LoanTransaction.t()} | {:error, NotFoundError.t()}
  def fetch_loan_transaction(id) do
    Repo.fetch(LoanTransaction, id)
  end

  @spec fetch_transaction(Transaction.id()) :: {:ok, Transaction.t()} | {:error, NotFoundError.t()}
  def fetch_transaction(id) do
    Repo.fetch(Transaction.preload_line_items(), id)
  end

  @spec lend(Account.t(), LoanTransaction.attrs()) :: {:ok, LoanTransaction.t()} | {:error, Changeset.t()}
  def lend(%Account{} = account, attrs \\ %{}) do
    %LoanTransaction{}
    |> LoanTransaction.loan_changeset(attrs)
    |> Repo.insert()
    |> cache_date(account)
    |> PubSub.broadcast(pubsub_topic(), :loan_transaction_created)
    |> case do
      {:ok, transaction} ->
        {:ok, transaction}

      {:error, %Changeset{} = changeset} ->
        {:error,
         %LoanTransaction{}
         |> LoanTransaction.changeset(attrs)
         |> Map.put(:action, changeset.action)
         |> Map.put(:errors, changeset.errors)}
    end
  end

  @spec list_fund_transactions(Fund.t(), [list_opt]) :: {[FundTransaction.t()], Paging.t()}
  def list_fund_transactions(%Fund{} = fund, opts \\ []) do
    limit = Keyword.get(opts, :per_page, 50)

    fund_transactions =
      fund
      |> LineItem.by_fund()
      |> LineItem.join_transaction()
      |> FundTransaction.with_running_balances()

    %Page{entries: transactions, metadata: metadata} =
      from(s in subquery(fund_transactions))
      |> FundTransaction.newest_first()
      |> Repo.paginate(
        after: opts[:next_cursor],
        before: opts[:prev_cursor],
        cursor_fields: FundTransaction.cursor_fields(),
        limit: limit
      )

    {transactions, %Paging{next_cursor: metadata.after, prev_cursor: metadata.before}}
  end

  @spec list_loan_transactions(Loan.t(), [list_opt]) :: {[LoanTransaction.t()], Paging.t()}
  def list_loan_transactions(%Loan{} = loan, opts \\ []) do
    limit = Keyword.get(opts, :per_page, 50)

    loan_transactions =
      loan
      |> LoanTransaction.by_loan()
      |> LoanTransaction.with_running_balances()

    %Page{entries: transactions, metadata: metadata} =
      from(s in subquery(loan_transactions))
      |> LoanTransaction.newest_first()
      |> Repo.paginate(
        after: opts[:next_cursor],
        before: opts[:prev_cursor],
        cursor_fields: LoanTransaction.cursor_fields(),
        limit: limit
      )

    {transactions, %Paging{next_cursor: metadata.after, prev_cursor: metadata.before}}
  end

  @spec new_loan_transaction(Loan.t()) :: Changeset.t()
  def new_loan_transaction(%Loan{} = loan) do
    LoanTransaction.changeset(%LoanTransaction{loan_id: loan.id}, %{date: default_date(loan.account_id)})
  end

  @spec new_transaction([Fund.t()]) :: Changeset.t()
  def new_transaction(funds) do
    line_items = Enum.map(funds, &%LineItem{fund_id: &1.id})

    %Transaction{}
    |> change_transaction(%{date: default_date(hd(funds).account_id)})
    |> Changeset.put_assoc(:line_items, line_items)
  end

  @spec receive_payment(Account.t(), LoanTransaction.attrs()) :: {:ok, LoanTransaction.t()} | {:error, Changeset.t()}
  def receive_payment(%Account{} = account, attrs \\ %{}) do
    %LoanTransaction{}
    |> LoanTransaction.payment_changeset(attrs)
    |> Repo.insert()
    |> cache_date(account)
    |> PubSub.broadcast(pubsub_topic(), :loan_transaction_created)
  end

  @spec regular_deposit(Account.t(), Date.t(), [Fund.t()]) ::
          {:ok, Transaction.t()} | {:error, InvariantError.t()}
  def regular_deposit(%Account{} = account, %Date{} = date, funds) do
    date
    |> regular_deposit_params(funds, account)
    |> then(&deposit(account, &1))
    |> case do
      {:ok, %Transaction{} = transaction} ->
        {:ok, transaction}

      {:error, changeset} ->
        ErrorReporter.call("Regular deposit failed", error: changeset)
        {:error, Error.invariant(message: "Unable to make regular deposit")}
    end
  end

  defp regular_deposit_params(%Date{} = date, funds, %Account{} = account) do
    line_items =
      funds
      |> Enum.map(
        &%{
          amount: Funds.regular_deposit_amount(&1, account),
          fund_id: &1.id
        }
      )
      |> Enum.reject(&Money.zero?(&1.amount))

    %{date: date, line_items: line_items, memo: "Regular deposit"}
  end

  @spec pubsub_topic :: PubSub.topic()
  def pubsub_topic, do: ProcessTree.get(:transactions_topic, default: "transactions")

  @spec update_loan_transaction(Account.t(), LoanTransaction.t(), LoanTransaction.attrs()) ::
          {:ok, LoanTransaction.t()} | {:error, Changeset.t()}
  def update_loan_transaction(%Account{} = account, %LoanTransaction{} = transaction, attrs) do
    transaction
    |> LoanTransaction.changeset(attrs)
    |> Repo.update()
    |> cache_date(account)
    |> PubSub.broadcast(pubsub_topic(), :loan_transaction_updated)
  end

  @spec update_transaction(Account.t(), Transaction.t(), Transaction.attrs()) ::
          {:ok, Transaction.t()} | {:error, Changeset.t()}
  def update_transaction(%Account{} = account, %Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
    |> cache_date(account)
    |> PubSub.broadcast(pubsub_topic(), :transaction_updated)
  end

  @spec withdraw(Account.t(), Transaction.attrs()) :: {:ok, Transaction.t()} | {:error, Changeset.t()}
  def withdraw(%Account{} = account, attrs \\ %{}) do
    funds = Funds.list_active_funds(account)

    %Transaction{}
    |> Transaction.withdrawal_changeset(attrs)
    |> Transaction.cover_overdrafts(funds, account.default_fund_id)
    |> Repo.insert()
    |> cache_date(account)
    |> PubSub.broadcast(pubsub_topic(), :transaction_created)
    |> case do
      {:ok, transaction} ->
        {:ok, transaction}

      {:error, changeset} ->
        {:error,
         %Transaction{}
         |> Transaction.changeset(attrs)
         |> Map.put(:action, changeset.action)
         |> Map.put(:errors, changeset.errors)}
    end
  end

  defp cache_date({:error, _error} = result, _account), do: result

  defp cache_date({:ok, transaction} = result, %Account{} = account) do
    cache = ProcessTree.get(:date_cache, default: DateCache)
    DateCache.remember(cache, account.id, transaction.date)
    result
  end

  defp default_date(account_id) do
    cache = ProcessTree.get(:date_cache, default: DateCache)
    DateCache.last_date(cache, account_id, Timex.today(:local))
  end
end
