defmodule FreedomAccount.Loans.Activation do
  @moduledoc """
  Embedded schema for bulk-updating loan active status.
  """
  use Ecto.Schema
  use TypedEctoSchema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Ecto.Schema
  alias FreedomAccount.Loans.Loan

  @type attrs :: %{optional(:loans) => %{index() => Loan.activation_attrs()}}
  @type index :: String.t()

  @primary_key false
  typed_embedded_schema do
    embeds_many :loans, Loan
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(activation, attrs) do
    activation
    |> cast(attrs, [])
    |> cast_embed(:loans, with: &Loan.activation_changeset/2)
  end
end
