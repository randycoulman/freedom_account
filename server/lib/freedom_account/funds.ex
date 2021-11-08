defmodule FreedomAccount.Funds do
  @moduledoc """
  Context for working with funds in a Freedom Account.
  """

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Repo

  @type fund :: Fund.t()

  @spec list_funds(account :: Account.t()) :: [fund]
  def list_funds(account) do
    account
    |> Ecto.assoc(:funds)
    |> Repo.all()
  end
end
