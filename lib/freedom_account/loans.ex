defmodule FreedomAccount.Loans do
  @moduledoc """
  Context for working with loans in a Freedom Account.
  """
  use Boundary,
    deps: [
      FreedomAccount.Accounts,
      FreedomAccount.Error,
      FreedomAccount.ErrorReporter,
      FreedomAccount.PubSub,
      FreedomAccount.Repo
    ],
    exports: [Loan]

  alias Ecto.Changeset
  alias Ecto.Multi
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotAllowedError
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Loans.Activation
  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.PubSub
  alias FreedomAccount.Repo

  require FreedomAccount.ErrorReporter, as: ErrorReporter

  @spec change_activation(Account.t(), Activation.attrs()) :: Changeset.t()
  def change_activation(%Account{} = account, attrs \\ %{}) do
    allowed_loans =
      account
      |> list_all_loans()
      |> Enum.filter(&Loan.can_change_activation?/1)

    Activation.changeset(%Activation{loans: allowed_loans}, attrs)
  end

  @spec change_loan(Loan.t(), Loan.attrs()) :: Changeset.t()
  def change_loan(%Loan{} = loan, attrs \\ %{}) do
    Loan.changeset(loan, attrs)
  end

  @spec create_loan(Account.t(), Loan.attrs()) :: {:ok, Loan.t()} | {:error, Changeset.t()}
  def create_loan(account, attrs \\ %{}) do
    %Loan{account_id: account.id}
    |> Loan.changeset(attrs)
    |> Repo.insert()
    |> PubSub.broadcast(pubsub_topic(), :loan_created)
  end

  @spec deactivate_loan(Loan.t()) :: {:ok, Loan.t()} | {:error, NotAllowedError.t()}
  def deactivate_loan(%Loan{} = loan) do
    if Loan.can_change_activation?(loan) do
      loan
      |> Loan.activation_changeset(%{active: false})
      |> Repo.update()
    else
      ErrorReporter.call("Attempt to deactivate a loan with a non-zero balance", metadata: %{loan_id: loan.id})
      {:error, Error.not_allowed(message: "A loan with a non-zero balance cannot be deactivated")}
    end
  end

  @spec delete_loan(Loan.t()) :: :ok | {:error, NotAllowedError.t()}
  def delete_loan(%Loan{} = loan) do
    loan
    |> Loan.deletion_changeset()
    |> Repo.delete()
    |> PubSub.broadcast(pubsub_topic(), :loan_deleted)
    |> case do
      {:ok, _loan} ->
        :ok

      {:error, _changeset} ->
        ErrorReporter.call("Attempt to delete a loan with transactions", metadata: %{loan_id: loan.id})
        {:error, Error.not_allowed(message: "A loan with transactions cannot be deleted")}
    end
  end

  @spec fetch_active_loan(Account.t(), Loan.id()) :: {:ok, Loan.t()} | {:error, NotFoundError.t()}
  def fetch_active_loan(%Account{} = account, id) do
    account
    |> Loan.by_account()
    |> Repo.fetch(id)
  end

  @spec list_active_loans(Account.t()) :: [Loan.t()]
  @spec list_active_loans(Account.t(), [Loan.id()] | nil) :: [Loan.t()]
  def list_active_loans(account, ids \\ nil) do
    account
    |> Loan.by_account()
    |> Loan.where_ids(ids)
    |> Loan.with_balance()
    |> Loan.order_by_name()
    |> Repo.all()
  end

  @spec list_all_loans(Account.t()) :: [Loan.t()]
  def list_all_loans(account) do
    Loan
    |> Loan.by_account(account)
    |> Loan.with_balance()
    |> Loan.order_by_name()
    |> Repo.all()
  end

  @spec pubsub_topic :: PubSub.topic()
  def pubsub_topic, do: ProcessTree.get(:loans_topic, default: "loans")

  @spec update_activation(Account.t(), Activation.attrs()) :: {:ok, [Loan.t()]} | {:error, Changeset.t()}
  def update_activation(%Account{} = account, attrs) do
    activation_changeset = change_activation(account, attrs)

    activation_changeset
    |> Changeset.get_embed(:loans)
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn {changeset, index}, multi ->
      Multi.update(multi, {:loan, index}, changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, changes} ->
        PubSub.broadcast({:ok, Map.values(changes)}, pubsub_topic(), :loan_activation_updated)

      {:error, {:loan, index}, changeset, _changes_so_far} ->
        {:error, Map.put(activation_changeset, index, changeset)}
    end
  end

  @spec update_loan(Loan.t(), Loan.attrs()) :: {:ok, Loan.t()} | {:error, Changeset.t()}
  def update_loan(%Loan{} = loan, attrs) do
    loan
    |> Loan.changeset(attrs)
    |> Repo.update()
    |> PubSub.broadcast(pubsub_topic(), :loan_updated)
  end

  @spec with_updated_balance(Loan.t()) :: {:ok, Loan.t()} | {:error, NotFoundError.t()}
  def with_updated_balance(%Loan{} = loan) do
    Loan
    |> Loan.with_balance()
    |> Repo.fetch(loan.id)
  end
end
