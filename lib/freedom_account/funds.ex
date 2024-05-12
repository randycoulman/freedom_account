defmodule FreedomAccount.Funds do
  @moduledoc """
  Context for working with funds in a Freedom Account.
  """

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Repo

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
