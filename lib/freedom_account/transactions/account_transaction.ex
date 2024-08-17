defmodule FreedomAccount.Transactions.AccountTransaction do
  @moduledoc false
  use TypedStruct

  import Ecto.Query

  alias Ecto.Queryable

  @type type :: :fund | :loan

  typedstruct enforce: true do
    field :amount, Money.t()
    field :date, Date.t()
    field :id, non_neg_integer()
    field :inserted_at, NaiveDateTime.t()
    field :memo, String.t()
    field :running_balance, Money.t(), default: Money.zero(:usd)
    field :type, type()
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

  @spec select_from_fund_transaction(Queryable.t()) :: Queryable.t()
  def select_from_fund_transaction(query) do
    from [line_item: l, transaction: t] in query,
      select: %__MODULE__{
        amount: type(sum(l.amount), l.amount),
        date: t.date,
        id: t.id,
        inserted_at: t.inserted_at,
        memo: t.memo,
        type: "fund"
      }
  end

  @spec select_from_loan_transaction(Queryable.t()) :: Queryable.t()
  def select_from_loan_transaction(query) do
    from t in query,
      select: %__MODULE__{
        amount: t.amount,
        date: t.date,
        id: t.id,
        inserted_at: t.inserted_at,
        memo: t.memo,
        type: "loan"
      }
  end

  @spec with_running_balances(Queryable.t()) :: Queryable.t()
  def with_running_balances(query) do
    from t in query,
      select_merge: %{running_balance: over(sum(t.amount), :transaction)},
      windows: [
        transaction: [
          order_by: [t.date, t.inserted_at, t.id]
        ]
      ]
  end
end
