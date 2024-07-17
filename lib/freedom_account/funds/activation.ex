defmodule FreedomAccount.Funds.Activation do
  @moduledoc """
  Embedded schema for bulk-updating fund active status.
  """
  use Ecto.Schema
  use TypedEctoSchema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Ecto.Schema
  alias FreedomAccount.Funds.Fund

  @type attrs :: %{optional(:funds) => %{index() => Fund.activation_attrs()}}
  @type index :: String.t()

  @primary_key false
  typed_embedded_schema do
    embeds_many :funds, Fund
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(activation, attrs) do
    activation
    |> cast(attrs, [])
    |> cast_embed(:funds, with: &Fund.activation_changeset/2)
  end
end
