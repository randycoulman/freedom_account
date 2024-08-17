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

  @type activation_attrs :: %{
          optional(:active) => boolean()
        }
  @type attrs :: %{
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

    field :active, :boolean, null: false, read_after_writes: true
    field(:budget, Money.Ecto.Composite.Type) :: Money.t()
    field :icon, :string, null: false
    field :name, :string, null: false
    field :times_per_year, :float

    has_many :line_items, LineItem

    field(:current_balance, Money.Ecto.Composite.Type, virtual: true) :: Money.t() | nil
    field(:regular_deposit_amount, Money.Ecto.Composite.Type, virtual: true) :: Money.t()

    timestamps()
  end

  @spec activation_changeset(Changeset.t() | Schema.t(), activation_attrs()) :: Changeset.t()
  def activation_changeset(fund, attrs) do
    fund
    |> cast(attrs, [:active])
    |> validate_required([:active])
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

  @spec can_change_activation?(t()) :: boolean()
  def can_change_activation?(%__MODULE__{} = fund) do
    not fund.active or Money.zero?(fund.current_balance)
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

  @spec regular_deposit_amount(t() | Changeset.t(), Account.t()) :: Money.t()
  def regular_deposit_amount(%__MODULE__{} = fund, %Account{} = account) do
    regular_deposit_amount(fund.budget, fund.times_per_year, account)
  end

  def regular_deposit_amount(%Changeset{} = changeset, %Account{} = account) do
    budget = Changeset.get_field(changeset, :budget)
    times_per_year = Changeset.get_field(changeset, :times_per_year)

    regular_deposit_amount(budget, times_per_year, account)
  end

  defp regular_deposit_amount(budget, times_per_year, %Account{} = account) do
    budget
    |> Money.mult!(times_per_year)
    |> Money.div!(account.deposits_per_year)
    |> Money.round(rounding_mode: :half_up)
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

  defp base_query do
    from f in __MODULE__,
      where: [active: true]
  end
end
