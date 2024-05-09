defmodule FreedomAccount.Repo.Migrations.AddMoneyWithCurrencyTypeToPostgres do
  use Ecto.Migration

  @spec up :: any()
  def up do
    execute("CREATE TYPE public.money_with_currency AS (currency_code varchar, amount numeric);")
  end

  @spec down :: any()
  def down do
    execute("DROP TYPE public.money_with_currency;")
  end
end
