defmodule FreedomAccount.Funds do
  @moduledoc """
  Context for working with funds in a Freedom Account.
  """

  alias Ecto.Changeset
  alias Ecto.Multi
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotAllowedError
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Funds.Budget
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.PubSub
  alias FreedomAccount.Repo

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

  @spec delete_fund(Fund.t()) :: :ok | {:error, NotAllowedError.t()}
  def delete_fund(%Fund{} = fund) do
    fund
    |> Fund.deletion_changeset()
    |> Repo.delete()
    |> PubSub.broadcast(pubsub_topic(), :fund_deleted)
    |> case do
      {:ok, _fund} -> :ok
      {:error, _changeset} -> {:error, Error.not_allowed(message: "A fund with transactions cannot be deleted")}
    end
  end

  @spec fetch_fund(Account.t(), Fund.id()) :: {:ok, Fund.t()} | {:error, NotFoundError.t()}
  def fetch_fund(%Account{} = account, id) do
    Fund
    |> Fund.by_account(account)
    |> Repo.fetch(id)
  end

  @spec list_funds(Account.t()) :: [Fund.t()]
  @spec list_funds(Account.t(), [Fund.id()] | nil) :: [Fund.t()]
  def list_funds(account, ids \\ nil) do
    Fund
    |> Fund.by_account(account)
    |> Fund.where_ids(ids)
    |> Fund.order_by_name()
    |> Fund.with_balance()
    |> Repo.all()
  end

  @spec pubsub_topic :: PubSub.topic()
  def pubsub_topic, do: ProcessTree.get(:funds_topic, default: "funds")

  defdelegate regular_deposit_amount(fund, deposits_per_year), to: Fund

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
