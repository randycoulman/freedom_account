defmodule FreedomAccount.Funds do
  @moduledoc """
  Context for working with funds in a Freedom Account.
  """

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Repo

  @doc """
  Returns the list of funds for an account.
  """
  @spec list_funds(Account.t()) :: [Fund.t()]
  def list_funds(account) do
    Fund
    |> Fund.by_account(account)
    |> Repo.all()
  end

  # @doc """
  # Gets a single fund.

  # Raises `Ecto.NoResultsError` if the Fund does not exist.

  # ## Examples

  #     iex> get_fund!(123)
  #     %Fund{}

  #     iex> get_fund!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_fund!(id), do: Repo.get!(Fund, id)

  @doc """
  Creates a fund.
  """
  @spec create_fund(Account.t(), Fund.attrs()) :: {:ok, Fund.t()} | {:error, Changeset.t()}
  def create_fund(account, attrs \\ %{}) do
    attrs = Map.put(attrs, :account_id, account.id)

    %Fund{}
    |> Fund.changeset(attrs)
    |> Repo.insert()
  end

  # @doc """
  # Updates a fund.

  # ## Examples

  #     iex> update_fund(fund, %{field: new_value})
  #     {:ok, %Fund{}}

  #     iex> update_fund(fund, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_fund(%Fund{} = fund, attrs) do
  #   fund
  #   |> Fund.changeset(attrs)
  #   |> Repo.update()
  # end

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

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking fund changes.

  # ## Examples

  #     iex> change_fund(fund)
  #     %Ecto.Changeset{data: %Fund{}}

  # """
  # def change_fund(%Fund{} = fund, attrs \\ %{}) do
  #   Fund.changeset(fund, attrs)
  # end
end
