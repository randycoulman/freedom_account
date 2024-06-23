defmodule FreedomAccount.Funds.Budget do
  @moduledoc """
  Embedded schema for bulk-updating fund budgets.
  """
  use Ecto.Schema
  use TypedEctoSchema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Ecto.Schema
  alias FreedomAccount.Funds.Fund

  @type attrs :: %{optional(:funds) => %{index() => Fund.budget_attrs()}}
  @type index :: String.t()

  @primary_key false
  typed_embedded_schema do
    embeds_many :funds, Fund
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [])
    |> cast_embed(:funds, with: &Fund.budget_changeset/2)
  end
end
