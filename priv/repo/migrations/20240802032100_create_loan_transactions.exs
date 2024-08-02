defmodule FreedomAccount.Repo.Migrations.CreateLoanTransactions do
  use Ecto.Migration

  @spec change :: any()
  def change do
    create table(:loan_transactions) do
      add :amount, :money_with_currency, null: false
      add :date, :date, null: false
      add :loan_id, references(:loans, on_delete: :restrict), null: false
      add :memo, :string, null: false

      timestamps()
    end
  end
end
