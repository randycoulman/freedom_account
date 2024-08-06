defmodule FreedomAccount.Funds do
  @moduledoc """
  Context for working with funds in a Freedom Account.
  """
  use Boundary,
    deps: [
      FreedomAccount.Accounts,
      FreedomAccount.Error,
      FreedomAccount.ErrorReporter,
      FreedomAccount.PubSub,
      FreedomAccount.Repo
    ],
    exports: [Fund]

  alias Ecto.Changeset
  alias Ecto.Multi
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotAllowedError
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Funds.Activation
  alias FreedomAccount.Funds.Budget
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.PubSub
  alias FreedomAccount.Repo

  require FreedomAccount.ErrorReporter, as: ErrorReporter

  @spec change_activation(Account.t(), Activation.attrs()) :: Changeset.t()
  def change_activation(%Account{} = account, attrs \\ %{}) do
    allowed_funds =
      account
      |> list_all_funds()
      |> Enum.filter(&Fund.can_change_activation?/1)

    Activation.changeset(%Activation{funds: allowed_funds}, attrs)
  end

  @spec change_budget([Fund.t()], Budget.attrs()) :: Changeset.t()
  def change_budget(funds, attrs \\ %{}) do
    Budget.changeset(%Budget{funds: funds}, attrs)
  end

  @spec change_fund(Fund.t(), Fund.attrs()) :: Changeset.t()
  def change_fund(%Fund{} = fund, attrs \\ %{}) do
    Fund.changeset(fund, attrs)
  end

  @spec create_fund(Account.t(), Fund.attrs()) :: {:ok, Fund.t()} | {:error, Changeset.t()}
  def create_fund(account, attrs \\ %{}) do
    %Fund{account_id: account.id}
    |> Fund.changeset(attrs)
    |> Repo.insert()
    |> PubSub.broadcast(pubsub_topic(), :fund_created)
  end

  @spec deactivate_fund(Fund.t()) :: {:ok, Fund.t()} | {:error, NotAllowedError.t()}
  def deactivate_fund(%Fund{} = fund) do
    if Fund.can_change_activation?(fund) do
      fund
      |> Fund.activation_changeset(%{active: false})
      |> Repo.update()
    else
      ErrorReporter.call("Attempt to deactivate a fund with a non-zero balance", metadata: %{fund_id: fund.id})
      {:error, Error.not_allowed(message: "A fund with a non-zero balance cannot be deactivated")}
    end
  end

  @spec delete_fund(Fund.t()) :: :ok | {:error, NotAllowedError.t()}
  def delete_fund(%Fund{} = fund) do
    fund
    |> Fund.deletion_changeset()
    |> Repo.delete()
    |> PubSub.broadcast(pubsub_topic(), :fund_deleted)
    |> case do
      {:ok, _fund} ->
        :ok

      {:error, _changeset} ->
        ErrorReporter.call("Attempt to delete a fund with transactions", metadata: %{fund_id: fund.id})
        {:error, Error.not_allowed(message: "A fund with transactions cannot be deleted")}
    end
  end

  @spec fetch_active_fund(Account.t(), Fund.id()) :: {:ok, Fund.t()} | {:error, NotFoundError.t()}
  def fetch_active_fund(%Account{} = account, id) do
    account
    |> Fund.by_account()
    |> Repo.fetch(id)
  end

  @spec list_active_funds(Account.t()) :: [Fund.t()]
  @spec list_active_funds(Account.t(), [Fund.id()] | nil) :: [Fund.t()]
  def list_active_funds(account, ids \\ nil) do
    account
    |> Fund.by_account()
    |> Fund.where_ids(ids)
    |> Fund.with_balance()
    |> Fund.order_by_name()
    |> Repo.all()
  end

  @spec list_all_funds(Account.t()) :: [Fund.t()]
  def list_all_funds(account) do
    Fund
    |> Fund.by_account(account)
    |> Fund.with_balance()
    |> Fund.order_by_name()
    |> Repo.all()
  end

  @spec pubsub_topic :: PubSub.topic()
  def pubsub_topic, do: ProcessTree.get(:funds_topic, default: "funds")

  defdelegate regular_deposit_amount(fund, deposits_per_year), to: Fund

  @spec update_activation(Account.t(), Activation.attrs()) :: {:ok, [Fund.t()]} | {:error, Changeset.t()}
  def update_activation(%Account{} = account, attrs) do
    activation_changeset = change_activation(account, attrs)

    activation_changeset
    |> Changeset.get_embed(:funds)
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn {changeset, index}, multi ->
      Multi.update(multi, {:fund, index}, changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, changes} ->
        PubSub.broadcast({:ok, Map.values(changes)}, pubsub_topic(), :fund_activation_updated)

      {:error, {:fund, index}, changeset, _changes_so_far} ->
        {:error, Map.put(activation_changeset, index, changeset)}
    end
  end

  @spec update_budget([Fund.t()], Budget.attrs()) :: {:ok, [Fund.t()]} | {:error, Changeset.t()}
  def update_budget(funds, attrs) do
    budget_changeset = change_budget(funds, attrs)

    budget_changeset
    |> Changeset.get_embed(:funds)
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn {changeset, index}, multi ->
      Multi.update(multi, {:fund, index}, changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, changes} ->
        PubSub.broadcast({:ok, Map.values(changes)}, pubsub_topic(), :budget_updated)

      {:error, {:fund, index}, changeset, _changes_so_far} ->
        {:error, Map.put(budget_changeset, index, changeset)}
    end
  end

  @spec update_fund(Fund.t(), Fund.attrs()) :: {:ok, Fund.t()} | {:error, Changeset.t()}
  def update_fund(%Fund{} = fund, attrs) do
    fund
    |> Fund.changeset(attrs)
    |> Repo.update()
    |> PubSub.broadcast(pubsub_topic(), :fund_updated)
  end

  @spec with_updated_balance(Fund.t()) :: {:ok, Fund.t()} | {:error, NotFoundError.t()}
  def with_updated_balance(%Fund{} = fund) do
    Fund
    |> Fund.with_balance()
    |> Repo.fetch(fund.id)
  end
end
