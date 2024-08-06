defimpl Phoenix.HTML.Safe, for: [FreedomAccount.Funds.Fund, FreedomAccount.Loans.Loan] do
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Loans.Loan

  @spec to_iodata(Fund.t() | Loan.t()) :: iodata()
  def to_iodata(%Fund{} = fund) do
    "#{fund.icon} #{fund.name}"
  end

  def to_iodata(%Loan{} = loan) do
    "#{loan.icon} #{loan.name}"
  end
end
