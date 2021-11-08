defmodule FreedomAccount.Repo.Migrations.AddFundsTable do
  use Ecto.Migration

  def change do
    create table("funds") do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :icon, :string, size: 10, null: false
      add :name, :string, size: 50, null: false

      timestamps()
    end
  end
end
