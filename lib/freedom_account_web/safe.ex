defimpl Phoenix.HTML.Safe, for: FreedomAccount.Funds.Fund do
  alias FreedomAccount.Funds.Fund

  @spec to_iodata(Fund.t()) :: iodata()
  def to_iodata(%Fund{} = fund) do
    "#{fund.icon} #{fund.name}"
  end
end
