defmodule FreedomAccount.Factory do
  @moduledoc false

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.LineItem
  alias FreedomAccount.Transactions.Transaction

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

  @spec date :: Date.t()
  def date, do: Faker.Date.backward(100)

  @spec deposit_count :: Account.deposit_count()
  def deposit_count, do: Faker.random_between(12, 26)

  @spec description :: String.t()
  def description, do: Faker.Lorem.sentence()

  @spec fund_icon :: Fund.icon()
  def fund_icon, do: Enum.random(@emoji)

  @spec fund_name :: Fund.name()
  def fund_name, do: Faker.Commerce.product_name()

  @spec id :: non_neg_integer()
  def id, do: Faker.random_between(1000, 1_000_000)

  @spec money :: Money.t()
  def money, do: Money.new("#{Enum.random(0..499)}.#{Enum.random(0..99)}", :usd)

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
    Enum.into(overrides, %{deposits_per_year: deposit_count(), name: account_name()})
  end

  @spec deposit(Fund.t(), Transaction.attrs()) :: Transaction.t()
  def deposit(fund, attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new()
      |> Map.put_new_lazy(:line_items, fn -> line_item_attrs(fund) end)
      |> transaction_attrs()

    {:ok, transaction} = Transactions.deposit(attrs)

    transaction
  end

  @spec fund(Account.t(), Fund.attrs()) :: Fund.t()
  def fund(account, attrs \\ %{}) do
    attrs = fund_attrs(attrs)
    {:ok, fund} = Funds.create_fund(account, attrs)

    fund
  end

  @spec fund_attrs(Fund.attrs()) :: Fund.attrs()
  def fund_attrs(overrides \\ %{}) do
    Enum.into(overrides, %{icon: fund_icon(), name: fund_name()})
  end

  @spec line_item_attrs(Fund.t(), LineItem.attrs()) :: LineItem.attrs()
  def line_item_attrs(fund, overrides \\ %{}) do
    Enum.into(overrides, %{amount: money(), fund_id: fund.id})
  end

  @spec transaction_attrs(Transaction.attrs()) :: Transaction.attrs()
  def transaction_attrs(overrides \\ %{}) do
    Enum.into(overrides, %{
      date: date(),
      description: description()
    })
  end
end
