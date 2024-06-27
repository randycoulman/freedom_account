defmodule FreedomAccount.Funds do
  @moduledoc """
  Context for working with funds in a Freedom Account.
  """

  alias Ecto.Changeset
  alias Ecto.Multi
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Budget
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.PubSub
  alias FreedomAccount.Repo

  @spec change_budget([Fund.t()], Budget.attrs()) :: Changeset.t()
  def change_budget(funds, attrs \\ %{}) do
    Budget.changeset(%Budget{funds: funds}, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking fund changes.
  """
  @spec change_fund(Fund.t(), Fund.attrs()) :: Changeset.t()
  def change_fund(%Fund{} = fund, attrs \\ %{}) do
    Fund.changeset(fund, attrs)
  end

  @doc """
  Creates a fund.
  """
  @spec create_fund(Account.t(), Fund.attrs()) :: {:ok, Fund.t()} | {:error, Changeset.t()}
  def create_fund(account, attrs \\ %{}) do
    %Fund{account_id: account.id}
    |> Fund.changeset(attrs)
    |> Repo.insert()
    |> PubSub.broadcast(pubsub_topic(), :fund_created)
  end

  @doc """
  Deletes a fund.

  ## Examples

      iex> delete_fund(fund)
      {:ok, %Fund{}}

      iex> delete_fund(fund)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_fund(Fund.t()) :: :ok | {:error, :fund_has_transactions}
  def delete_fund(%Fund{} = fund) do
    fund
    |> Fund.deletion_changeset()
    |> Repo.delete()
    |> PubSub.broadcast(pubsub_topic(), :fund_deleted)
    |> case do
      {:ok, _fund} -> :ok
      {:error, _changeset} -> {:error, :fund_has_transactions}
    end
  end

  @doc """
  Looks up a single fund by id.

  ## Examples

      iex> fetch_fund(account, 123)
      {:ok, %Fund{}}

      iex> fetch_fund(account, 456)
      {:error, :not_found}

  """
  @spec fetch_fund(Account.t(), Fund.id()) :: {:ok, Fund.t()} | {:error, :not_found}
  def fetch_fund(%Account{} = account, id) do
    Fund
    |> Fund.by_account(account)
    |> Repo.fetch(id)
  end

  @doc """
  Looks up a single fund by id, including its current balance.

  ## Examples

      iex> fetch_fund_with_balance(account, 123)
      {:ok, %Fund{}}

      iex> fetch_fund_with_balance(account, 456)
      {:error, :not_found}

  """
  @spec fetch_fund_with_balance(Account.t(), Fund.id()) :: {:ok, Fund.t()} | {:error, :not_found}
  def fetch_fund_with_balance(%Account{} = account, id) do
    Fund
    |> Fund.by_account(account)
    |> Fund.with_balance()
    |> Repo.fetch(id)
  end

  @doc """
  Returns the list of funds for an account.
  """
  @spec list_funds(Account.t()) :: [Fund.t()]
  def list_funds(account) do
    Fund
    |> Fund.by_account(account)
    |> Fund.order_by_name()
    |> Repo.all()
  end

  @doc """
  Returns the list of funds for an account, including each fund's current
  balance.
  """
  @spec list_funds_with_balances(Account.t()) :: [Fund.t()]
  def list_funds_with_balances(account) do
    Fund
    |> Fund.by_account(account)
    |> Fund.order_by_name()
    |> Fund.with_balance()
    |> Repo.all()
  end

  @spec pubsub_topic :: PubSub.topic()
  def pubsub_topic, do: ProcessTree.get(:funds_topic, default: "funds")

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

  @doc """
  Updates a fund.

  ## Examples

      iex> update_fund(fund, %{field: new_value})
      {:ok, %Fund{}}

      iex> update_fund(fund, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_fund(Fund.t(), Fund.attrs()) :: {:ok, Fund.t()} | {:error, Changeset.t()}
  def update_fund(%Fund{} = fund, attrs) do
    fund
    |> Fund.changeset(attrs)
    |> Repo.update()
    |> PubSub.broadcast(pubsub_topic(), :fund_updated)
  end

  @doc """
  Reloads a fund's current balance.
  """
  @spec with_updated_balance(Fund.t()) :: {:ok, Fund.t()} | {:error, :not_found}
  def with_updated_balance(%Fund{} = fund) do
    Fund
    |> Fund.with_balance()
    |> Repo.fetch(fund.id)
  end
end
