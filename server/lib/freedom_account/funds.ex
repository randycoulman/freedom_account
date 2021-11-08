defmodule FreedomAccount.Funds do
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Fund

  @type fund :: Fund.t()

  @fake_funds [
    Fund.new("🏚️", "Home Repairs"),
    Fund.new("🚘", "Car Repairs"),
    Fund.new("💸", "Property Taxes")
  ]

  @spec list_funds(account :: Account.t()) :: {:ok, [fund]} | {:error, term}
  def list_funds(_account) do
    {:ok, @fake_funds}
  end
end
