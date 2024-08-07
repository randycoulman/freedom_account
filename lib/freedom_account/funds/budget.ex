defmodule FreedomAccount.Funds.Budget do
  @moduledoc """
  Embedded schema for bulk-updating fund budgets.
  """
  use Ecto.Schema
  use TypedEctoSchema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Ecto.Schema
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds.Fund

  @type attrs :: %{optional(:funds) => %{index() => Fund.budget_attrs()}}
  @type index :: String.t()

  @primary_key false
  typed_embedded_schema do
    belongs_to :account, Account
    field(:total_deposit_amount, Money.Ecto.Composite.Type) :: Money.t()
    embeds_many :funds, Fund
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [])
    |> cast_embed(:funds, with: &Fund.budget_changeset/2)
    |> compute_totals()
  end

  defp compute_totals(%Changeset{} = changeset) do
    account = get_field(changeset, :account)

    updated_funds =
      changeset
      |> get_embed(:funds)
      |> Enum.map(&put_change(&1, :regular_deposit_amount, Fund.regular_deposit_amount(&1, account)))

    total =
      Enum.reduce(updated_funds, Money.zero(:usd), &(&1 |> get_field(:regular_deposit_amount) |> Money.add!(&2)))

    changeset
    |> put_embed(:funds, updated_funds)
    |> put_change(:total_deposit_amount, total)
  end
end
