defmodule FreedomAccount.Transactions.FundTransaction do
  @moduledoc false
  use TypedStruct

  import Ecto.Query

  alias Ecto.Queryable

  typedstruct enforce: true do
    field :amount, Money.t()
    field :date, Date.t()
    field :id, non_neg_integer()
    field :memo, String.t()
  end

  @spec newest_first(Queryable.t()) :: Queryable.t()
  def newest_first(query) do
    from [line_item: l, transaction: t] in query,
      order_by: [desc: t.date, desc: l.inserted_at, desc: l.id]
  end

  @spec select(Queryable.t()) :: Queryable.t()
  def select(query) do
    from [line_item: l, transaction: t] in query,
      select: %__MODULE__{
        amount: l.amount,
        date: t.date,
        id: l.id,
        memo: t.memo
      }
  end
end
