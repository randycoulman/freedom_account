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
          optional(:budget) => Money.t(),
          optional(:icon) => icon(),
          optional(:name) => name(),
          optional(:times_per_year) => float()
        }
  @type budget_attrs :: %{
          optional(:budget) => Money.t(),
          optional(:id) => id(),
          optional(:times_per_year) => float()
        }
  @type icon :: String.t()
  @type id :: non_neg_integer()
  @type name :: String.t()

  typed_schema "funds" do
    belongs_to :account, Account

    field(:budget, Money.Ecto.Composite.Type) :: Money.t()
    field :icon, :string, null: false
    field :name, :string, null: false
    field :times_per_year, :float

    has_many :line_items, LineItem

    field(:current_balance, Money.Ecto.Composite.Type, virtual: true) :: Money.t() | nil

    timestamps()
  end

  @spec budget_changeset(Changeset.t() | Schema.t(), budget_attrs()) :: Changeset.t()
  def budget_changeset(fund, attrs) do
    fund
    |> cast(attrs, [:budget, :times_per_year])
    |> validate_required([:budget, :times_per_year])
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs) :: Changeset.t()
  def changeset(fund, attrs) do
    fund
    |> cast(attrs, [:budget, :icon, :name, :times_per_year])
    |> validate_required([:budget, :icon, :name, :times_per_year])
    |> validate_length(:icon, max: 10)
    |> validate_length(:name, max: 50)
  end

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

  @spec regular_deposit_amount(t(), Account.deposit_count()) :: Money.t()
  def regular_deposit_amount(%__MODULE__{} = fund, deposits_per_year) do
    fund.budget
    |> Money.mult!(fund.times_per_year)
    |> Money.div!(deposits_per_year)
    |> Money.round()
  end

  @spec where_ids([id()] | nil) :: Queryable.t()
  @spec where_ids(Queryable.t(), [id()] | nil) :: Queryable.t()
  def where_ids(query \\ base_query(), ids \\ nil)

  def where_ids(query, nil), do: query

  def where_ids(query, ids) do
    from f in query,
      where: f.id in ^ids
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
