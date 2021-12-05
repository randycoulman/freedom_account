defmodule FreedomAccount.Accounts do
  @moduledoc """
  Context for working with Freedom Accounts.
  """

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Authentication.User
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Repo

  @type account :: Account.t()
  @type account_id :: Account.id()
  @type account_params :: Account.params()
  @type update_error :: :not_found | Changeset.t()

  @spec account_for_user(user :: User.t()) :: {:ok, account} | {:error, :not_found}
  def account_for_user(%User{} = user) do
    Account
    |> Account.for_user(user)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  @spec find_account(id :: account_id) :: {:ok, account} | {:error, :not_found}
  def find_account(id) do
    case Repo.get(Account, id) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  @spec reset_account(account :: account) :: :ok
  def reset_account(%Account{} = account) do
    user_id = account.user_id
    Repo.delete!(account)

    new_account = Repo.insert!(%Account{name: "Initial Account", user_id: user_id})

    Repo.insert!(%Fund{
      account: new_account,
      icon: "🏚️",
      name: "Home Repairs"
    })

    Repo.insert!(%Fund{
      account: new_account,
      icon: "🚘",
      name: "Car Repairs"
    })

    Repo.insert!(%Fund{
      account: new_account,
      icon: "💸",
      name: "Property Taxes"
    })

    :ok
  end

  @spec update_account(params :: account_params) :: {:ok, account} | {:error, update_error}
  def update_account(params) do
    with {id, params} <- Map.pop(params, :id),
         {:ok, account} <- account_with_id(id) do
      account
      |> Account.changeset(params)
      |> Repo.update()
    end
  end

  defp account_with_id(id) do
    case Repo.get(Account, id) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end
end
