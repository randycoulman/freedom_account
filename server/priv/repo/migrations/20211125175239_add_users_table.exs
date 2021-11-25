defmodule FreedomAccount.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :name, :string, size: 20, null: false

      timestamps()
    end
  end
end
