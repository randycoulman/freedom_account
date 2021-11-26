defmodule FreedomAccount.Factory do
  @moduledoc """
  Factories for building test data.
  """

  # credo:disable-for-this-file Credo.Check.Readability.Specs

  use ExMachina.Ecto, repo: FreedomAccount.Repo

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Users.User

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
    %Account{
      deposits_per_year: Faker.random_between(12, 26),
      id: Ecto.UUID.generate(),
      name: Faker.Company.name(),
      user: build(:user)
    }
  end

  def fund_factory do
    %Fund{
      icon: random_emoji(),
      id: Ecto.UUID.generate(),
      name: Faker.Commerce.product_name()
    }
  end

  def user_factory do
    %User{
      id: Ecto.UUID.generate(),
      name: Faker.Person.first_name()
    }
  end

  defp random_emoji do
    Enum.random(@emoji)
  end
end
