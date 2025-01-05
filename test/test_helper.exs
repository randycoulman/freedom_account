ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(FreedomAccount.Repo, :manual)
{:ok, _apps} = Application.ensure_all_started(:ex_machina)
