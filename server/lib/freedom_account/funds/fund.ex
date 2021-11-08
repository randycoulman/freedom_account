defmodule FreedomAccount.Funds.Fund do
  use Ecto.Schema

  @type icon :: String.t()
  @type id :: Ecto.UUID.t()
  @type name :: String.t()
  @type t :: %__MODULE__{
          icon: icon,
          id: id,
          name: name
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  embedded_schema do
    field :icon, :string
    field :name, :string
  end

  def new(icon, name, id \\ Ecto.UUID.generate()) do
    %__MODULE__{
      icon: icon,
      id: id,
      name: name
    }
  end
end
