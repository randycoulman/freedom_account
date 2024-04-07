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
  Looks up a single fund by id.

  ## Examples

      iex> fetch_fund(123)
      {:ok, %Fund{}}

      iex> fetch_fund(456)
      {:error, :not_found}

  """
  @spec fetch_fund(Fund.id()) :: {:ok, Fund.t()} | {:error, :not_found}
  def fetch_fund(id), do: Repo.fetch(Fund, id)

  @doc """
  Returns the list of funds for an account.
  """
  @spec list_funds(Account.t()) :: [Fund.t()]
  def list_funds(account) do
    Fund
    |> Fund.by_account(account)
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

  # @doc """
  # Deletes a fund.

  # ## Examples

  #     iex> delete_fund(fund)
  #     {:ok, %Fund{}}

  #     iex> delete_fund(fund)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_fund(%Fund{} = fund) do
  #   Repo.delete(fund)
  # end
end
