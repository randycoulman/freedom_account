defmodule FreedomAccount.Repo.Migrations.AddBudgetFieldsToFunds do
  use Ecto.Migration

  @spec change :: any()
  def change do
    alter table(:funds) do
      add :budget, :money_with_currency, default: fragment("('USD',0)"), null: false
      add :times_per_year, :float, default: 1.0, null: false
    end
  end
end
