defmodule FreedomAccount.Funds.Fund do
  @moduledoc """
  An individual fund in a Freedom Account.
  """

  use FreedomAccount.Schema

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Schema

  @type icon :: String.t()
  @type id :: Schema.id()
  @type name :: String.t()
  @type params :: %{
          :icon => icon,
          :name => name,
          optional(:id) => id
        }
  @type t :: %__MODULE__{
          account: Schema.belongs_to(Account.t()),
          icon: icon,
          id: id,
          inserted_at: DateTime.t() | nil,
          name: name,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "funds" do
    belongs_to :account, Account
    field :icon, :string
    field :name, :string

    timestamps()
  end

  @spec changeset(fund :: Changeset.t() | Schema.t(), params :: params) :: Changeset.t()
  def changeset(fund, params) do
    fund
    |> cast(params, [:icon, :id, :name])
    |> validate_required([:icon, :name])
    |> validate_length(:icon, max: 10)
    |> validate_length(:name, max: 50)
  end
end
