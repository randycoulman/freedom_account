defmodule FreedomAccount.MoneyUtils do
  @moduledoc false
  use Boundary

  @spec sum([Money.t()]) :: Money.t()
  def sum(monies) do
    Enum.reduce(monies, Money.zero(:usd), &Money.add!/2)
  end
end
