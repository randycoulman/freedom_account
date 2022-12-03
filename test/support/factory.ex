defmodule FreedomAccount.Factory do
  @moduledoc false

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account

  @spec account_name :: Account.name()
  def account_name, do: Faker.Company.name()

  @spec deposit_count :: Account.deposit_count()
  def deposit_count, do: Faker.random_between(12, 26)

  @spec account(Account.attrs()) :: Account.t()
  def account(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> account_attrs()
      |> Accounts.create_account()

    account
  end

  @spec account_attrs(Account.attrs()) :: Account.attrs()
  def account_attrs(overrides \\ %{}) do
    overrides
    |> Enum.into(%{
      deposits_per_year: deposit_count(),
      name: account_name()
    })
  end
end
