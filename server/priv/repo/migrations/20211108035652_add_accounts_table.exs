defmodule FreedomAccount.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :name, :string, size: 50, null: false

      timestamps()
    end
  end
end
