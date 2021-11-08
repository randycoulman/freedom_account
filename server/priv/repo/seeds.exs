# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias FreedomAccount.Accounts.Account
alias FreedomAccount.Repo

Repo.insert!(%Account{name: "Initial Account"})
