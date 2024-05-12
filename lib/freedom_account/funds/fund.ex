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
  alias FreedomAccount.Transactions.LineItem

  @type attrs :: %{
          optional(:account_id) => non_neg_integer,
          optional(:icon) => icon,
          optional(:name) => name
        }
  @type icon :: String.t()
  @type id :: non_neg_integer()
  @type name :: String.t()

  typed_schema "funds" do
    belongs_to :account, Account

    field :icon, :string, null: false
    field :name, :string, null: false

    has_many :line_items, LineItem

    field(:current_balance, Money.Ecto.Composite.Type, virtual: true) :: Money.t() | nil

    timestamps()
  end

  @doc false
  @spec changeset(Changeset.t() | Schema.t(), attrs) :: Changeset.t()
  def changeset(fund, attrs) do
    fund
    |> cast(attrs, [:icon, :name])
    |> validate_required([:icon, :name])
    |> validate_length(:icon, max: 10)
    |> validate_length(:name, max: 50)
  end

  @doc false
  @spec deletion_changeset(Changeset.t() | Schema.t()) :: Changeset.t()
  def deletion_changeset(fund) do
    fund
    |> cast(%{}, [])
    |> foreign_key_constraint(:line_items, name: :line_items_fund_id_fkey)
  end

  @spec by_account(Account.t()) :: Queryable.t()
  @spec by_account(Queryable.t(), Account.t()) :: Queryable.t()
  def by_account(query \\ base_query(), account) do
    from f in query,
      where: [account_id: ^account.id]
  end

  @spec order_by_name :: Queryable.t()
  @spec order_by_name(Queryable.t()) :: Queryable.t()
  def order_by_name(query \\ base_query()) do
    from f in query,
      order_by: f.name
  end

  @spec with_balance :: Queryable.t()
  @spec with_balance(Queryable.t()) :: Queryable.t()
  def with_balance(query \\ base_query()) do
    zero = Money.zero(:usd)

    from f in query,
      left_join: l in assoc(f, :line_items),
      group_by: f.id,
      select_merge: %{current_balance: type(coalesce(sum(l.amount), ^zero), l.amount)}
  end

  defp base_query, do: __MODULE__
end
