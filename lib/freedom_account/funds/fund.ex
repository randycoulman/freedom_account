defmodule FreedomAccount.Funds.Fund do
  @moduledoc """
  An individual fund in a Freedom Account.
  """

  use TypedEctoSchema

  import Ecto.Changeset
  import Ecto.Query

  alias Ecto.Changeset
  alias Ecto.Queryable
  alias Ecto.Schema
  alias FreedomAccount.Accounts.Account

  @type attrs :: %{
          optional(:account_id) => non_neg_integer,
          optional(:icon) => icon,
          optional(:name) => name
        }
  @type icon :: String.t()
  @type name :: String.t()

  typed_schema "funds" do
    belongs_to :account, Account

    field :icon, :string, null: false
    field :name, :string, null: false

    timestamps()
  end

  @doc false
  @spec changeset(Changeset.t() | Schema.t(), attrs) :: Changeset.t()
  def changeset(fund, attrs) do
    fund
    |> cast(attrs, [:account_id, :icon, :name])
    |> validate_required([:account_id, :icon, :name])
    |> validate_length(:icon, max: 10)
    |> validate_length(:name, max: 50)
  end

  @spec by_account(Account.t()) :: Queryable.t()
  @spec by_account(Queryable.t(), Account.t()) :: Queryable.t()
  def by_account(query \\ base_query(), account) do
    from f in query,
      where: [account_id: ^account.id]
  end

  defp base_query, do: __MODULE__
end
