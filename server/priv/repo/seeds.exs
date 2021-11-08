# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias FreedomAccount.Accounts.Account
alias FreedomAccount.Funds.Fund
alias FreedomAccount.Repo

account =
  case Repo.one(Account) do
    nil ->
      Repo.insert!(%Account{name: "Initial Account"})

    account ->
      account
  end

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
