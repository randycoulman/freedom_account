defmodule FreedomAccount.Funds.Fund do
  @moduledoc """
  An individual fund in a Freedom Account.
  """

  use FreedomAccount.Schema

  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Schema

  @type icon :: String.t()
  @type id :: Schema.id()
  @type name :: String.t()
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
end
