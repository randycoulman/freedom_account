# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

defmodule Seeds do
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Repo
  alias FreedomAccount.Users.User

  def call do
    ensure_user_exists("randy")
    ensure_user_exists("cypress")
    ensure_account_exists()
  end

  defp ensure_user_exists(name) do
    case Repo.get_by(User, name: name) do
      nil -> Repo.insert!(%User{name: name})
      user -> user
    end
  end

  defp ensure_account_exists do
    account =
      case Repo.one(Account) do
        nil ->
          Repo.insert!(%Account{name: "Initial Account"})

        account ->
          account
      end

    ensure_funds_exist(account)
    account
  end

  defp ensure_funds_exist(account) do
    unless Ecto.assoc(account, :funds) |> Repo.exists?() do
      Repo.insert!(%Fund{
        account: account,
        icon: "🏚️",
        name: "Home Repairs"
      })

      Repo.insert!(%Fund{
        account: account,
        icon: "🚘",
        name: "Car Repairs"
      })

      Repo.insert!(%Fund{
        account: account,
        icon: "💸",
        name: "Property Taxes"
      })
    end
  end
end

Seeds.call()
