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
  end

  defp base_changeset(line_item, attrs) do
    line_item
    |> cast(attrs, [:amount, :fund_id])
    |> validate_required([:amount, :fund_id])
    |> validate_money(:amount, not_equal_to: Money.zero(:usd))
  end

  defp negate(%Money{} = money), do: Money.mult!(money, -1)
end
