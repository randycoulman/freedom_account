defmodule FreedomAccount.Balances.Summary do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :funds, Money.t()
    field :loans, Money.t()
    field :total, Money.t()
  end
end
