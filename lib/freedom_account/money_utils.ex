defmodule FreedomAccount.MoneyUtils do
  @moduledoc false
  use Boundary

  @spec negate(Money.t()) :: Money.t()
  def negate(%Money{} = money), do: Money.mult!(money, -1)

  @spec sum([Money.t()]) :: Money.t()
  def sum(monies) do
    Enum.reduce(monies, &Money.add!/2)
  end
end
