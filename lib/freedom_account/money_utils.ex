defmodule FreedomAccount.MoneyUtils do
  @moduledoc false
  use Boundary

  @spec format(Money.t()) :: String.t()
  def format(%Money{} = money) do
    if Money.negative?(money) do
      "(#{Money.negate!(money)})"
    else
      Money.to_string!(money)
    end
  end

  @spec sum([Money.t()]) :: Money.t()
  def sum(monies) do
    Enum.reduce(monies, Money.zero(:usd), &Money.add!/2)
  end
end
