defmodule FreedomAccount.Repo.Migrations.CreateFunds do
  @moduledoc false
  use Ecto.Migration

  @spec change :: any
  def change do
    create table(:funds) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :icon, :string, null: false, size: 10
      add :name, :string, null: false, size: 50

      timestamps()
    end
  end
end
