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
    field :running_balance, Money.t()
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
  def cursor_fields, do: [{:date, :desc}, {:inserted_at, :desc}, {:id, :desc}]

  @spec newest_first(Queryable.t()) :: Queryable.t()
  def newest_first(query) do
    from t in query,
      order_by: [desc: t.date, desc: t.inserted_at, desc: t.id]
  end

  @spec with_running_balances(Queryable.t()) :: Queryable.t()
  def with_running_balances(query) do
    from [line_item: l, transaction: t] in query,
      select: %__MODULE__{
        amount: l.amount,
        date: t.date,
        id: l.id,
        inserted_at: l.inserted_at,
        memo: t.memo,
        running_balance: over(sum(l.amount), :fund)
      },
      windows: [
        fund: [
          order_by: [t.date, l.inserted_at, l.id],
          partition_by: l.fund_id
        ]
      ]
  end
end