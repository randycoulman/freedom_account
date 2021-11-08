defmodule FreedomAccount.Accounts.Account do
  @moduledoc """
  A Freedom Account.
  """

  use FreedomAccount.Schema

  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Schema

  @type id :: Schema.id()
  @type name :: String.t()
  @type t :: %__MODULE__{
          funds: Schema.has_many(Fund.t()),
          id: id,
          inserted_at: DateTime.t() | nil,
          name: name,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    has_many :funds, Fund
    field :name, :string

    timestamps()
  end
end
