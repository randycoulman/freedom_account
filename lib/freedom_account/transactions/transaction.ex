defmodule FreedomAccount.Transactions.Transaction do
  @moduledoc """
  A transaction in a Freedom Account.
  """
  use TypedEctoSchema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Ecto.Schema
  alias FreedomAccount.Transactions.LineItem

  @type attrs :: %{
          optional(:date) => Date.t(),
          optional(:memo) => String.t(),
          optional(:line_items) => [LineItem.attrs()]
        }
  @type partial :: %__MODULE__{}

  typed_schema "transactions" do
    field :date, :date
    field :memo, :string

    has_many :line_items, LineItem

    timestamps()
  end

  @doc false
  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(transaction, attrs) do
    base_changeset(transaction, attrs)
  end

  @doc false
  @spec deposit_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def deposit_changeset(transaction, attrs) do
    base_changeset(transaction, attrs, with: &LineItem.deposit_changeset/2)
  end

  @doc false
  @spec withdrawal_changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def withdrawal_changeset(transaction, attrs) do
    base_changeset(transaction, attrs, with: &LineItem.withdrawal_changeset/2)
  end

  defp base_changeset(transaction, attrs, opts \\ []) do
    transaction
    |> cast(attrs, [:date, :memo])
    |> validate_required([:date, :memo])
    |> cast_assoc(:line_items, [required: true] ++ opts)
  end
end
