defmodule FreedomAccount.Balances do
  @moduledoc false
  use Boundary, deps: [FreedomAccount.Accounts, FreedomAccount.Funds, FreedomAccount.Loans], exports: [Summary]

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Balances.Summary
  alias FreedomAccount.Funds
  alias FreedomAccount.Loans

  @spec summary(Account.t()) :: Summary.t()
  def summary(%Account{} = account) do
    funds_balance = account |> Funds.list_active_funds() |> calculate_balance()
    loans_balance = account |> Loans.list_active_loans() |> calculate_balance()

    %Summary{
      funds: funds_balance,
      loans: loans_balance,
      total: Money.add!(funds_balance, loans_balance)
    }
  end

  defp calculate_balance(list) do
    Enum.reduce(list, Money.zero(:usd), &Money.add!(&1.current_balance, &2))
  end
end
