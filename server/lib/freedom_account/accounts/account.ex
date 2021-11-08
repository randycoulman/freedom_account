defmodule FreedomAccount.Accounts.Account do
  use Ecto.Schema

  @type id :: Ecto.UUID.t()
  @type name :: String.t()
  @type t :: %__MODULE__{
          id: id,
          name: name
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  embedded_schema do
    field :name, :string
  end

  def new(name \\ "My Freedom Account", id \\ Ecto.UUID.generate()) do
    %__MODULE__{
      id: id,
      name: name
    }
  end
end
