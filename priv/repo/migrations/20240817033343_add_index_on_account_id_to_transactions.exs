defmodule FreedomAccount.Repo.Migrations.AddIndexOnAccountIdToTransactions do
  use Ecto.Migration

  @spec change :: any()
  def change do
    create index(:transactions, [:account_id])
  end
end
