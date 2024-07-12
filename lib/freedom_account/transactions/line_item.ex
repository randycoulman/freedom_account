defmodule FreedomAccount.Transactions.LineItem do
  @moduledoc """
  A line item of a `FreedomAccount.Transactions.Transaction` in a Freedom
  Account.
  """
  use TypedEctoSchema

  import Ecto.Changeset
  import Money.Validate

  alias Ecto.Changeset
  alias Ecto.Schema
  alias FreedomAccount.Funds.Fund

  @type attrs :: %{
          optional(:amount) => Money.t(),
          optional(:fund_id) => non_neg_integer()
        }

  typed_schema "line_items" do
    field(:amount, Money.Ecto.Composite.Type) :: Money.t()
    field :fund_id, :integer
    field :transaction_id, :integer

    timestamps()
  end

  @spec avoid_overdraft(Changeset.t(), %{Fund.id() => Fund.t()}) :: {Changeset.t(), Money.t()}
  def avoid_overdraft(%Changeset{} = changeset, funds_by_index) do
    fund_id = get_field(changeset, :fund_id)
    amount = get_field(changeset, :amount)
    fund = Map.fetch!(funds_by_index, fund_id)
    difference = Money.add!(fund.current_balance, amount)

    if Money.negative?(difference) do
      updated_changeset = put_change(changeset, :amount, Money.mult!(fund.current_balance, -1))
      {updated_changeset, Money.mult!(difference, -1)}
    else
      {changeset, Money.zero(:usd)}
    end
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(line_item, attrs) do
    base_changeset(line_item, attrs)
  end

  @spec deposit_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def deposit_changeset(line_item, attrs) do
    base_changeset(line_item, attrs)
  end

  @spec withdrawal_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def withdrawal_changeset(line_item, attrs) do
    line_item
    |> base_changeset(attrs)
    |> update_change(:amount, &negate/1)
    |> ignore_if_amount_missing()
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

  defp negate(%Money{} = money), do: Money.mult!(money, -1)
end
