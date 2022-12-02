defmodule FreedomAccount.Repo.Migrations.CreateAccounts do
  @moduledoc false
  use Ecto.Migration

  @spec change :: any
  def change do
    create table(:accounts) do
      add :deposits_per_year, :integer, default: 24, null: false
      add :name, :string, null: false, size: 50

      timestamps()
    end
  end
end
