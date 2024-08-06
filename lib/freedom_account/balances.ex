defmodule FreedomAccount.Balances do
  @moduledoc false
  use Boundary, deps: [FreedomAccount.Accounts, FreedomAccount.Funds, FreedomAccount.Loans]

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Loans
  alias FreedomAccount.Loans.Loan

  @spec account_balance(Account.t()) :: Money.t()
  def account_balance(%Account{} = account) do
    fund_balance =
      account
      |> Funds.list_active_funds()
      |> Enum.reduce(Money.zero(:usd), fn %Fund{} = fund, acc ->
        Money.add!(acc, fund.current_balance)
      end)

    loan_balance =
      account
      |> Loans.list_active_loans()
      |> Enum.reduce(Money.zero(:usd), fn %Loan{} = loan, acc ->
        Money.add!(acc, loan.current_balance)
      end)

    Money.add!(fund_balance, loan_balance)
  end
end
