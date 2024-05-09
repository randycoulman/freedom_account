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
          optional(:description) => String.t(),
          optional(:line_items) => [LineItem.attrs()]
        }
  @type partial :: %__MODULE__{}

  typed_schema "transactions" do
    field :date, :date
    field :description, :string

    has_many :line_items, LineItem

    timestamps()
  end

  @doc false
  @spec changeset(Changeset.t() | Schema.t(), attrs()) :: Changeset.t()
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :description])
    |> default_to_today()
    |> cast_assoc(:line_items, required: true)
    |> validate_required([:date, :description])
  end

  defp default_to_today(%Changeset{} = changeset) do
    if Changeset.get_field(changeset, :date) do
      changeset
    else
      Changeset.put_change(changeset, :date, Timex.today(:local))
    end
  end
end
