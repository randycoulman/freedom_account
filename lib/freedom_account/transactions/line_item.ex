defmodule FreedomAccount.Transactions.LineItem do
  @moduledoc """
  A line item of a `FreedomAccount.Transactions.Transaction` in a Freedom
  Account.
  """
  use TypedEctoSchema

  import Ecto.Changeset
  import Ecto.Query
  import Money.Validate

  alias Ecto.Changeset
  alias Ecto.Queryable
  alias Ecto.Schema
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Transactions.Transaction

  @type attrs :: %{
          optional(:amount) => Money.t(),
          optional(:fund_id) => Fund.id()
        }

  typed_schema "line_items" do
    belongs_to :fund, Fund
    belongs_to :transaction, Transaction

    field(:amount, Money.Ecto.Composite.Type) :: Money.t()

    timestamps()
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(line_item, attrs) do
    base_changeset(line_item, attrs)
  end

  @spec avoid_overdraft(Changeset.t(), %{Fund.id() => Fund.t()}) :: {Changeset.t(), Money.t()}
  def avoid_overdraft(%Changeset{} = changeset, funds_by_index) do
    fund_id = get_field(changeset, :fund_id)
    amount = get_field(changeset, :amount)
    fund = Map.fetch!(funds_by_index, fund_id)
    difference = Money.add!(fund.current_balance, amount)

    if Money.negative?(difference) do
      updated_changeset = put_change(changeset, :amount, MoneyUtils.negate(fund.current_balance))
      {updated_changeset, MoneyUtils.negate(difference)}
    else
      {changeset, Money.zero(:usd)}
    end
  end

  @spec deposit_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def deposit_changeset(line_item, attrs) do
    base_changeset(line_item, attrs)
  end

  @spec withdrawal_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def withdrawal_changeset(line_item, attrs) do
    line_item
    |> base_changeset(attrs)
    |> update_change(:amount, &MoneyUtils.negate/1)
    |> ignore_if_amount_missing()
  end

  @spec by_fund(Fund.t()) :: Queryable.t()
  @spec by_fund(Queryable.t(), Fund.t()) :: Queryable.t()
  def by_fund(query \\ base_query(), %Fund{} = fund) do
    from [line_item: l] in query,
      where: [fund_id: ^fund.id]
  end

  @spec join_fund :: Queryable.t()
  @spec join_fund(Queryable.t()) :: Queryable.t()
  def join_fund(query \\ base_query()) do
    from [line_item: l] in query,
      join: f in assoc(l, :fund),
      as: :fund
  end

  @spec join_transaction :: Queryable.t()
  @spec join_transaction(Queryable.t()) :: Queryable.t()
  def join_transaction(query \\ base_query()) do
    from [line_item: l] in query,
      join: t in assoc(l, :transaction),
      as: :transaction
  end

  defp ignore_if_amount_missing(%Changeset{} = changeset) do
    amount = Changeset.get_field(changeset, :amount)

    if is_nil(amount) or Money.zero?(amount) do
      %{changeset | action: :ignore}
    else
      changeset
    end
  end

  defp base_changeset(line_item, attrs) do
    line_item
    |> cast(attrs, [:amount, :fund_id])
    |> validate_required([:amount, :fund_id])
    |> validate_money(:amount, not_equal_to: Money.zero(:usd))
  end

  defp base_query do
    from __MODULE__, as: :line_item
  end
end
