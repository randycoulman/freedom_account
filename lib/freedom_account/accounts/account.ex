defmodule FreedomAccount.Accounts.Account do
  @moduledoc """
  A Freedom Account.
  """

  use TypedEctoSchema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Ecto.Schema

  @type attrs :: %{
          optional(:deposits_per_year) => deposit_count,
          optional(:name) => name
        }
  @type deposit_count :: non_neg_integer
  @type id :: non_neg_integer
  @type name :: String.t()

  typed_schema "accounts" do
    field :deposits_per_year, :integer, null: false
    field :name, :string, null: false

    timestamps()
  end

  @doc false
  @spec changeset(Changeset.t() | Schema.t(), attrs) :: Changeset.t()
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:deposits_per_year, :name])
    |> validate_required([:deposits_per_year, :name])
    |> validate_number(:deposits_per_year, greater_than: 0)
    |> validate_length(:name, max: 50)
  end
end
