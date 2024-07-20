defmodule FreedomAccount.Transactions.FundTransaction do
  @moduledoc false
  use TypedStruct

  import Ecto.Query

  alias Ecto.Queryable

  typedstruct enforce: true do
    field :amount, Money.t()
    field :date, Date.t()
    field :id, non_neg_integer()
    field :inserted_at, NaiveDateTime.t()
    field :memo, String.t()
  end

  @spec compare(t(), t()) :: :eq | :gt | :lt
  def compare(%__MODULE__{} = a, %__MODULE__{} = b) do
    with :eq <- Date.compare(a.date, b.date),
         :eq <- NaiveDateTime.compare(a.inserted_at, b.inserted_at) do
      cond do
        a.id > b.id -> :gt
        a.id < b.id -> :lt
        true -> :eq
      end
    end
  end

  @spec cursor_fields :: list()
  def cursor_fields, do: [{{:transaction, :date}, :desc}, {{:line_item, :inserted_at}, :desc}, {{:line_item, :id}, :desc}]

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
        inserted_at: l.inserted_at,
        memo: t.memo
      }
  end
end
