defmodule FreedomAccount.Transactions do
  @moduledoc """
  Context for working with transactions in a Freedom Account.
  """
  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error
  alias FreedomAccount.Error.InvariantError
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.PubSub
  alias FreedomAccount.Repo
  alias FreedomAccount.Transactions.LineItem
  alias FreedomAccount.Transactions.Transaction

  @spec change_transaction(Transaction.t(), Transaction.attrs()) :: Changeset.t()
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  @spec deposit(Transaction.attrs()) :: {:ok, Transaction.t()} | {:error, Changeset.t()}
  def deposit(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.deposit_changeset(attrs)
    |> Repo.insert()
    |> PubSub.broadcast(pubsub_topic(), :transaction_created)
  end

  @spec new_transaction([Fund.t()]) :: Changeset.t()
  def new_transaction(funds) do
    line_items = Enum.map(funds, &%LineItem{fund_id: &1.id})

    %Transaction{}
    |> change_transaction(%{date: Timex.today(:local)})
    |> Changeset.put_assoc(:line_items, line_items)
  end

  @spec regular_deposit(Date.t(), [Fund.t()], Account.deposit_count()) ::
          {:ok, Transaction.t()} | {:error, InvariantError.t()}
  def regular_deposit(%Date{} = date, funds, deposits_per_year) do
    line_items =
      funds
      |> Enum.map(
        &%LineItem{
          amount: Funds.regular_deposit_amount(&1, deposits_per_year),
          fund_id: &1.id
        }
      )
      |> Enum.reject(&Money.zero?(&1.amount))

    %Transaction{date: date, line_items: line_items, memo: "Regular deposit"}
    |> Repo.insert()
    |> PubSub.broadcast(pubsub_topic(), :transaction_created)
    |> case do
      {:ok, %Transaction{} = transaction} -> {:ok, transaction}
      {:error, _changeset} -> {:error, Error.invariant(message: "Unable to make regular deposit")}
    end
  end

  @spec pubsub_topic :: PubSub.topic()
  def pubsub_topic, do: ProcessTree.get(:transactions_topic, default: "transactions")

  @spec withdraw(Transaction.attrs()) :: {:ok, Transaction.t()} | {:error, Changeset.t()}
  def withdraw(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.withdrawal_changeset(attrs)
    |> Repo.insert()
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
end
