defmodule FreedomAccount.Factory do
  # use ExMachina.Ecto, repo: FreedomAccount.Repo
  use ExMachina

  alias FreedomAccount.Accounts.Account
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

  def account_factory do
    Account.new(Faker.Company.name())
  end

  def fund_factory do
    Fund.new(random_emoji(), Faker.Commerce.product_name())
  end

  defp random_emoji do
    Enum.random(@emoji)
  end
end
