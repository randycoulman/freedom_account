defmodule FreedomAccount.Loans.Loan do
  @moduledoc """
  An individual loan in a Freedom Account.
  """

  use TypedEctoSchema

  import Ecto.Changeset
  import Ecto.Query

  alias Ecto.Changeset
  alias Ecto.Queryable
  alias Ecto.Schema
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Transactions.LoanTransaction

  @type activation_attrs :: %{
          optional(:active) => boolean()
        }
  @type attrs :: %{
          optional(:account_id) => non_neg_integer,
          optional(:icon) => icon(),
          optional(:name) => name()
        }
  @type icon :: String.t()
  @type id :: non_neg_integer()
  @type name :: String.t()

  typed_schema "loans" do
    belongs_to :account, Account

    field :active, :boolean, read_after_writes: true
    field :icon, :string
    field :name, :string

    has_many :transactions, LoanTransaction

    field(:current_balance, Money.Ecto.Composite.Type, virtual: true) :: Money.t() | nil

    timestamps()
  end

  @spec activation_changeset(Changeset.t() | Schema.t(), activation_attrs()) :: Changeset.t()
  def activation_changeset(loan, attrs) do
    loan
    |> cast(attrs, [:active])
    |> validate_required([:active])
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs) :: Changeset.t()
  def changeset(loan, attrs) do
    loan
    |> cast(attrs, [:icon, :name])
    |> validate_required([:icon, :name])
    |> validate_length(:icon, max: 10)
    |> validate_length(:name, max: 50)
  end

  @spec can_change_activation?(t()) :: boolean()
  def can_change_activation?(%__MODULE__{} = loan) do
    not loan.active or Money.zero?(loan.current_balance)
  end

  @spec deletion_changeset(Changeset.t() | Schema.t()) :: Changeset.t()
  def deletion_changeset(loan) do
    loan
    |> cast(%{}, [])
    |> foreign_key_constraint(:transactions, name: :loan_transactions_loan_id_fkey)
  end

  @spec by_account(Account.t()) :: Queryable.t()
  @spec by_account(Queryable.t(), Account.t()) :: Queryable.t()
  def by_account(query \\ base_query(), account) do
    from l in query,
      where: [account_id: ^account.id]
  end

  @spec order_by_name :: Queryable.t()
  @spec order_by_name(Queryable.t()) :: Queryable.t()
  def order_by_name(query \\ base_query()) do
    from l in query,
      order_by: l.name
  end

  @spec where_ids([id()] | nil) :: Queryable.t()
  @spec where_ids(Queryable.t(), [id()] | nil) :: Queryable.t()
  def where_ids(query \\ base_query(), ids \\ nil)

  def where_ids(query, nil), do: query

  def where_ids(query, ids) do
    from l in query,
      where: l.id in ^ids
  end

  @spec with_balance :: Queryable.t()
  @spec with_balance(Queryable.t()) :: Queryable.t()
  def with_balance(query \\ base_query()) do
    zero = Money.zero(:usd)

    from l in query,
      left_join: t in assoc(l, :transactions),
      group_by: l.id,
      select_merge: %{current_balance: type(coalesce(sum(t.amount), ^zero), t.amount)}
  end

  defp base_query do
    from l in __MODULE__,
      where: [active: true]
  end
end
