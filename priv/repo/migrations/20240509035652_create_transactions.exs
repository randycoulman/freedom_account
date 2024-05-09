defmodule FreedomAccount.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  @spec change :: any()
  def change do
    create table(:transactions) do
      add :date, :date, null: false
      add :description, :string, null: false

      timestamps()
    end
  end
end
