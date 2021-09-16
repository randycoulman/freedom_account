defmodule FreedomAccount.Release do
  @moduledoc """
  Tasks to run in a released application.

  These tasks allow us to run database migrations and seeding for the released
  application.  They are used by custom distillery commands (see
  `server/rel/commands`).

  Adapted from https://hexdocs.pm/ecto_sql/Ecto.Migrator.html.
  """
  @app :freedom_account

  @spec migrate :: :ok
  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &run_migrations/1)
    end

    :ok
  end

  @spec rollback(Ecto.Repo.t(), binary) :: :ok
  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    :ok
  end

  @spec seed :: :ok
  def seed do
    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          run_migrations(repo)
          run_seeds(repo)
        end)
    end

    :ok
  end

  defp run_migrations(repo) do
    Ecto.Migrator.run(repo, :up, all: true)
  end

  defp run_seeds(repo) do
    seed_script = priv_path_for(repo, "seeds.exs")

    if File.exists?(seed_script) do
      IO.puts("Running seed script..")
      Code.eval_file(seed_script)
    end
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    priv_dir = "#{:code.priv_dir(app)}"

    Path.join([priv_dir, repo_underscore, filename])
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
