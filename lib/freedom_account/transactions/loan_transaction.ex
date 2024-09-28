defmodule FreedomAccount.Transactions.LoanTransaction do
  @moduledoc """
  A transaction for a loan in a FreedomAccount.
  """
  use TypedEctoSchema

  import Ecto.Changeset
  import Ecto.Query
  import Money.Validate

  alias Ecto.Changeset
  alias Ecto.Queryable
  alias Ecto.Schema
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Loans.Loan
  alias Money.Ecto.Composite.Type, as: MoneyEctoType

  @type attrs :: %{
          optional(:amount) => Money.t(),
          optional(:date) => Date.t(),
          optional(:loan_id) => Loan.id(),
          optional(:memo) => String.t()
        }
  @type id :: non_neg_integer()

  typed_schema "loan_transactions" do
    belongs_to :loan, Loan

    field :account_id, :integer
    field(:amount, MoneyEctoType) :: Money.t()
    field :date, :date
    field :memo, :string

    field(:running_balance, MoneyEctoType, virtual: true) :: Money.t()

    timestamps()
  end

  @spec by_account(Account.t()) :: Queryable.t()
  @spec by_account(Queryable.t(), Account.t()) :: Queryable.t()
  def by_account(query \\ base_query(), %Account{} = account) do
    from l in query,
      where: [account_id: ^account.id]
  end

  @spec by_loan(Loan.t()) :: Queryable.t()
  @spec by_loan(Queryable.t(), Loan.t()) :: Queryable.t()
  def by_loan(query \\ base_query(), %Loan{} = loan) do
    from l in query,
      where: [loan_id: ^loan.id]
  end

  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :date, :loan_id, :memo])
    |> validate_required([:amount, :date, :loan_id, :memo])
    |> validate_money(:amount, not_equal_to: Money.zero(:usd))
  end

  @spec compare(t(), t()) :: :eq | :gt | :lt
  def compare(%__MODULE__{} = a, %__MODULE__{} = b) do
    with :eq <- Date.compare(a.date, b.date),
         :eq <- NaiveDateTime.compare(a.inserted_at, b.inserted_at) do
      cond do
        a.id > b.id -> :gt
        a.id < b.id -> :lt
        true -> :eq
      end
    end
  end

  @spec cursor_fields :: list()
  def cursor_fields, do: [{:date, :desc}, {:inserted_at, :desc}, {:id, :desc}]

  @spec join_loan :: Queryable.t()
  @spec join_loan(Queryable.t()) :: Queryable.t()
  def join_loan(query \\ base_query()) do
    from [transaction: t] in query,
      join: l in assoc(t, :loan),
      as: :loan
  end

  @spec loan_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def loan_changeset(transaction, attrs) do
    transaction
    |> changeset(attrs)
    |> update_change(:amount, &Money.negate!/1)
  end

  @spec newest_first(Queryable.t()) :: Queryable.t()
  def newest_first(query) do
    from l in query,
      order_by: [desc: l.date, desc: l.inserted_at, desc: l.id]
  end

  @spec payment_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def payment_changeset(transaction, attrs) do
    changeset(transaction, attrs)
  end

  @spec with_running_balances(Queryable.t()) :: Queryable.t()
  def with_running_balances(query) do
    from l in query,
      select_merge: %{running_balance: over(sum(l.amount), :loan)},
      windows: [
        loan: [
          order_by: [l.date, l.inserted_at, l.id],
          partition_by: l.loan_id
        ]
      ]
  end

  defp base_query do
    from __MODULE__, as: :transaction
  end
end
