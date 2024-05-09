defmodule FreedomAccount.Repo.Migrations.CreateLineItems do
  use Ecto.Migration

  @spec change :: any()
  def change do
    create table(:line_items) do
      add :amount, :money_with_currency, null: false
      add :fund_id, references(:funds, on_delete: :delete_all), null: false
      add :transaction_id, references(:transactions, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
