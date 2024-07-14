defmodule FreedomAccount.Repo.Migrations.AddActiveToFunds do
  use Ecto.Migration

  @spec change :: any()
  def change do
    alter table(:funds) do
      add :active, :boolean, default: true, null: false
    end
  end
end
