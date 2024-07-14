defmodule FreedomAccount.Factory do
  @moduledoc false
  import ExMachina, only: [sequence: 1]

  alias FreedomAccount.Accounts
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Budget
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
  def account_name, do: sequence("Account ")

  @spec date :: Date.t()
  def date, do: Faker.Date.backward(100)

  @spec deposit_count :: Account.deposit_count()
  def deposit_count, do: Faker.random_between(12, 26)

  @spec fund_icon :: Fund.icon()
  def fund_icon, do: Enum.random(@emoji)

  @spec fund_name :: Fund.name()
  def fund_name, do: sequence("Fund ")

  @spec id :: non_neg_integer()
  def id, do: Faker.random_between(1000, 1_000_000)

  @spec memo :: String.t()
  def memo, do: Faker.Lorem.sentence()

  @spec money :: Money.t()
  def money, do: Money.new("#{Enum.random(0..499)}.#{Enum.random(0..99)}", :usd)

  @spec one_of(list()) :: term()
  def one_of(items), do: Enum.random(items)

  @spec times_per_year :: float()
  def times_per_year, do: one_of([0.5, 1.0, 2.0, 4.0])

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

  @spec budget_attrs([Fund.t()], Fund.budget_attrs()) :: Budget.attrs()
  def budget_attrs(funds, attrs \\ %{}) do
    fund_attrs =
      funds
      |> Enum.map(&fund_budget_attrs(&1.id, attrs))
      |> Enum.with_index()
      |> Map.new(fn {attrs, index} -> {to_string(index), attrs} end)

    %{funds: fund_attrs}
  end

  @spec deposit(Fund.t(), Transaction.attrs() | %{amount: Money.t()} | keyword()) :: Transaction.t()
  def deposit(fund, attrs \\ %{}) do
    attrs = Map.new(attrs)
    {amount, attrs} = Map.pop(attrs, :amount)
    line_item = if amount, do: %{amount: amount}, else: %{}

    attrs =
      attrs
      |> Map.put_new_lazy(:line_items, fn ->
        [line_item_attrs(fund, line_item)]
      end)
      |> transaction_attrs()

    {:ok, transaction} = Transactions.deposit(attrs)

    transaction
  end

  @spec fund(Account.t(), Fund.attrs()) :: Fund.t()
  def fund(account, attrs \\ %{}) do
    attrs = fund_attrs(attrs)
    {:ok, fund} = Funds.create_fund(account, attrs)

    case attrs[:current_balance] do
      %Money{} = balance -> %{fund | current_balance: balance}
      nil -> fund
    end
  end

  @spec fund_attrs(Fund.attrs()) :: Fund.attrs()
  def fund_attrs(overrides \\ %{}) do
    Enum.into(overrides, %{
      # This is done automatically by the database
      # active?: true,
      budget: money(),
      icon: fund_icon(),
      name: fund_name(),
      times_per_year: times_per_year()
    })
  end

  @spec fund_budget_attrs(Fund.id(), Fund.budget_attrs()) :: Fund.budget_attrs()
  def fund_budget_attrs(id, overrides \\ %{}) do
    Enum.into(overrides, %{
      budget: money(),
      id: id,
      times_per_year: times_per_year()
    })
  end

  @spec inactive_fund(Account.t(), Fund.attrs()) :: Fund.t()
  def inactive_fund(account, attrs \\ %{}) do
    account
    |> fund(attrs)
    |> Funds.deactivate_fund!()
  end

  @spec line_item_attrs(Fund.t(), LineItem.attrs()) :: LineItem.attrs()
  def line_item_attrs(fund, overrides \\ %{}) do
    Enum.into(overrides, %{amount: money(), fund_id: fund.id})
  end

  @spec transaction_attrs(Transaction.attrs()) :: Transaction.attrs()
  def transaction_attrs(overrides \\ %{}) do
    Enum.into(overrides, %{
      date: date(),
      memo: memo()
    })
  end

  @spec with_default_fund(Account.t(), Fund.t()) :: Account.t()
  def with_default_fund(%Account{} = account, %Fund{} = fund) do
    %{account | default_fund_id: fund.id}
  end

  @spec with_balance(Fund.t()) :: Fund.t()
  @spec with_balance(Fund.t(), Money.t()) :: Fund.t()
  def with_balance(%Fund{} = fund, balance \\ money()) do
    unless Money.zero?(balance) do
      deposit(fund, amount: balance)
    end

    %{fund | current_balance: balance}
  end
end
