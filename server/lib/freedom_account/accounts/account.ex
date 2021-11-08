defmodule FreedomAccount.Accounts.Account do
  use Ecto.Schema

  @type id :: Ecto.UUID.t()
  @type name :: String.t()
  @type t :: %__MODULE__{
          id: id,
          inserted_at: DateTime.t() | nil,
          name: name,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    field :name, :string

    timestamps()
  end
end
