defmodule FreedomAccount.Transactions.Transaction do
  @moduledoc """
  A transaction in a Freedom Account.
  """
  use TypedEctoSchema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Ecto.Schema
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.MoneyUtils
  alias FreedomAccount.Transactions.LineItem

  @type attrs :: %{
          optional(:date) => Date.t(),
          optional(:memo) => String.t(),
          optional(:line_items) => [LineItem.attrs()]
        }

  typed_schema "transactions" do
    field :date, :date
    field :memo, :string
    field(:total, Money.Ecto.Composite.Type, virtual: true) :: Money.t() | nil

    has_many :line_items, LineItem

    timestamps()
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(transaction, attrs) do
    base_changeset(transaction, attrs)
  end

  @spec cover_overdrafts(Changeset.t(), [Fund.t()], Fund.id()) :: Changeset.t()
  def cover_overdrafts(%Changeset{valid?: false} = changeset, _funds, _default_fund_id) do
    changeset
  end

  def cover_overdrafts(%Changeset{} = changeset, _funds, nil = _default_fund_id) do
    changeset
  end

  def cover_overdrafts(%Changeset{} = changeset, funds, default_fund_id) do
    funds_by_index = Map.new(funds, &{&1.id, &1})

    {line_items, overdrafts} =
      changeset
      |> get_assoc(:line_items)
      |> Enum.map(&LineItem.avoid_overdraft(&1, funds_by_index))
      |> Enum.unzip()

    overdraft_amount = MoneyUtils.sum(overdrafts)

    if Money.zero?(overdraft_amount) do
      changeset
    else
      new_line_item = LineItem.withdrawal_changeset(%LineItem{}, %{amount: overdraft_amount, fund_id: default_fund_id})
      Changeset.put_assoc(changeset, :line_items, [new_line_item | line_items])
    end
  end

  @spec deposit_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def deposit_changeset(transaction, attrs) do
    base_changeset(transaction, attrs, with: &LineItem.deposit_changeset/2)
  end

  @spec withdrawal_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def withdrawal_changeset(transaction, attrs) do
    base_changeset(transaction, attrs, with: &LineItem.withdrawal_changeset/2)
  end

  defp base_changeset(transaction, attrs, opts \\ []) do
    default_opts = [required: true, required_message: "Requires at least one line item with a non-zero amount"]

    transaction
    |> cast(attrs, [:date, :memo])
    |> validate_required([:date, :memo])
    |> cast_assoc(:line_items, default_opts ++ opts)
    |> compute_total()
  end

  defp compute_total(%Changeset{} = changeset) do
    total =
      changeset
      |> get_assoc(:line_items)
      |> Enum.map(&get_field(&1, :amount))
      |> Enum.reject(&is_nil/1)
      |> MoneyUtils.sum()

    put_change(changeset, :total, total)
  end
end
