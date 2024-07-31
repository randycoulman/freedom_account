defmodule FreedomAccount.Repo.Migrations.CreateLoans do
  use Ecto.Migration

  @spec change :: any
  def change do
    create table(:loans) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :active, :boolean, default: true, null: false
      add :icon, :string, null: false, size: 10
      add :name, :string, null: false, size: 50

      timestamps()
    end
  end
end
