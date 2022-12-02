defmodule FreedomAccount.Accounts do
  @moduledoc """
  Context for working with Freedom Accounts.
  """

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Repo

  @spec only_account :: Account.t()
  def only_account do
    case Repo.fetch_one(Account) do
      {:ok, account} ->
        account

      {:error, :not_found} ->
        {:ok, account} = create_account(%{deposits_per_year: 24, name: "Initial Account"})
        account
    end
  end

  @doc """
  Creates an account.
  """
  @spec create_account(Account.attrs()) :: {:ok, Account.t()} | {:error, Changeset.t()}
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  # @doc """
  # Updates a account.

  # ## Examples

  #     iex> update_account(account, %{field: new_value})
  #     {:ok, %Account{}}

  #     iex> update_account(account, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_account(%Account{} = account, attrs) do
  #   account
  #   |> Account.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking account changes.

  # ## Examples

  #     iex> change_account(account)
  #     %Ecto.Changeset{data: %Account{}}

  # """
  # def change_account(%Account{} = account, attrs \\ %{}) do
  #   Account.changeset(account, attrs)
  # end
end
