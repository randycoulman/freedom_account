defmodule FreedomAccount.Balances do
  @moduledoc false
  use Boundary, deps: [FreedomAccount.Accounts, FreedomAccount.Funds]

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund

  @spec account_balance(Account.t()) :: Money.t()
  def account_balance(%Account{} = account) do
    account
    |> Funds.list_active_funds()
    |> Enum.reduce(Money.zero(:usd), fn %Fund{} = fund, acc ->
      Money.add!(acc, fund.current_balance)
    end)
  end
end
