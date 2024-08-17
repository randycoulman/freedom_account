defmodule FreedomAccount.Repo.Migrations.AddAccountIdToTransactions do
  use Ecto.Migration

  @spec up :: any()
  def up do
    alter table(:transactions) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end

    execute "UPDATE transactions SET account_id = (SELECT id FROM accounts LIMIT 1)"

    alter table(:transactions) do
      modify :account_id, :integer, null: false
    end
  end

  @spec down :: any()
  def down do
    alter table(:transactions) do
      remove :account_id
    end
  end
end
