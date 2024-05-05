defmodule FreedomAccount.Repo.Migrations.AddDefaultFundToAccount do
  use Ecto.Migration

  @spec change :: any
  def change do
    alter table(:accounts) do
      add :default_fund_id, references(:funds, on_delete: :nilify_all)
    end
  end
end
