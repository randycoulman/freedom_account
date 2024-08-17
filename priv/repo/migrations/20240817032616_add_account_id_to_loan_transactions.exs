defmodule FreedomAccount.Repo.Migrations.AddAccountIdToLoanTransactions do
  use Ecto.Migration

  @spec up :: any()
  def up do
    alter table(:loan_transactions) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end

    execute "UPDATE loan_transactions SET account_id = (SELECT id FROM accounts LIMIT 1)"

    alter table(:loan_transactions) do
      modify :account_id, :integer, null: false
    end

    create index(:loan_transactions, [:account_id])
  end

  @spec down :: any()
  def down do
    alter table(:loan_transactions) do
      remove :account_id
    end
  end
end
