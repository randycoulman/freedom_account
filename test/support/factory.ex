defmodule FreedomAccount.Factory do
  @moduledoc false

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund

  @emoji [
    "🎨",
    "⚡️",
    "🔥",
    "🐛",
    "🚑️",
    "✨",
    "📝",
    "🚀",
    "💄",
    "🎉",
    "✅",
    "🔒️",
    "🔖",
    "🚨",
    "🚧",
    "💚",
    "⬇️",
    "⬆️",
    "📌",
    "👷",
    "📈",
    "♻️",
    "➕",
    "➖",
    "🔧",
    "🔨",
    "🌐",
    "✏️",
    "💩",
    "⏪️",
    "🔀",
    "📦️",
    "👽️",
    "🚚",
    "📄",
    "💥",
    "🍱",
    "♿️",
    "💡",
    "🍻",
    "💬",
    "🗃️",
    "🔊",
    "🔇",
    "👥",
    "🚸",
    "🏗️",
    "📱",
    "🤡",
    "🥚",
    "🙈",
    "📸",
    "⚗️",
    "🔍️",
    "🏷️",
    "🌱",
    "🚩",
    "🥅",
    "💫",
    "🗑️",
    "🛂",
    "🧐",
    "⚰️",
    "🧪",
    "👔"
  ]

  @spec account_name :: Account.name()
  def account_name, do: Faker.Company.name()

  @spec deposit_count :: Account.deposit_count()
  def deposit_count, do: Faker.random_between(12, 26)

  @spec fund_icon :: Fund.icon()
  def fund_icon, do: Enum.random(@emoji)

  @spec fund_name :: Fund.name()
  def fund_name, do: Faker.Commerce.product_name()

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

  @spec fund(Account.t(), Fund.attrs()) :: Fund.t()
  def fund(account, attrs \\ %{}) do
    attrs = fund_attrs(attrs)
    {:ok, fund} = Funds.create_fund(account, attrs)

    fund
  end

  @spec fund_attrs(Fund.attrs()) :: Fund.attrs()
  def fund_attrs(overrides \\ %{}) do
    overrides
    |> Enum.into(%{
      icon: fund_icon(),
      name: fund_name()
    })
  end
end
