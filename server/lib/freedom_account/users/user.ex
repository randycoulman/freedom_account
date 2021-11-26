defmodule FreedomAccount.Users.User do
  @moduledoc """
  A user.
  """

  use FreedomAccount.Schema

  alias FreedomAccount.Schema

  @type id :: Schema.id()
  @type name :: String.t()
  @type t :: %__MODULE__{
          id: id,
          inserted_at: DateTime.t() | nil,
          name: name,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :name, :string

    timestamps()
  end
end
