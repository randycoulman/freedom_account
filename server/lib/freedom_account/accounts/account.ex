defmodule FreedomAccount.Accounts.Account do
  @moduledoc """
  A Freedom Account.
  """

  use FreedomAccount.Schema

  import Ecto.Query, only: [from: 2]

  alias Ecto.Changeset
  alias Ecto.Queryable
  alias FreedomAccount.Authentication.User
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Schema

  @type deposit_count :: non_neg_integer()
  @type id :: Schema.id()
  @type name :: String.t()
  @type params :: %{
          deposits_per_year: deposit_count,
          id: id,
          name: name
        }
  @type t :: %__MODULE__{
          deposits_per_year: deposit_count,
          funds: Schema.has_many(Fund.t()),
          id: id,
          inserted_at: DateTime.t() | nil,
          name: name,
          updated_at: DateTime.t() | nil,
          user: Schema.belongs_to(User.t())
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    belongs_to :user, User
    has_many :funds, Fund
    field :deposits_per_year, :integer
    field :name, :string

    timestamps()
  end

  @spec changeset(account :: Changeset.t() | Schema.t(), params :: params) :: Changeset.t()
  def changeset(account, params) do
    account
    |> cast(params, [:deposits_per_year, :name])
    |> validate_required([:deposits_per_year, :name])
    |> validate_number(:deposits_per_year, greater_than: 0)
    |> validate_length(:name, max: 50)
  end

  @spec for_user(query :: Queryable.t(), user :: User.t()) :: Queryable.t()
  def for_user(query, %User{id: user_id}) do
    from a in query, where: a.user_id == ^user_id
  end
end
