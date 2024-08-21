defimpl Phoenix.HTML.Safe,
  for: [FreedomAccount.Funds.Fund, FreedomAccount.Loans.Loan, FreedomAccount.Transactions.AccountTransaction] do
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Loans.Loan
  alias FreedomAccount.Transactions.AccountTransaction

  @spec to_iodata(Fund.t() | Loan.t() | AccountTransaction.t()) :: iodata()
  def to_iodata(%{icon: icon, name: name}) do
    "#{icon} #{name}"
  end
end
