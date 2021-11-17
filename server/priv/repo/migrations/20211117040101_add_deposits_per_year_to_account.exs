defmodule FreedomAccount.Repo.Migrations.AddDepositsPerYearToAccount do
  use Ecto.Migration

  def change do
    alter table("accounts") do
      add :deposits_per_year, :integer, default: 24, null: false
    end
  end
end
