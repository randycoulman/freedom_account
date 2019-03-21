defmodule FreedomAccount.ReleaseTasks do
  @moduledoc """
  Tasks to run in a released application.

  These tasks allow us to run database migrations and seeding for the released
  application.  They are used by custom distillery commands (see
  `server/rel/commands`).

  Adapted from https://hexdocs.pm/distillery/guides/running_migrations.html
  with inpout from https://gist.github.com/jswny/83e03537830b0d997924e8f1965d88bc.
  """

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql
  ]

  @otp_app :freedom_account
  @repos Application.get_env(@otp_app, :ecto_repos, [])

  @spec migrate([String.t()]) :: :ok
  def migrate(_argv) do
    start_services()
    run_migrations()
    stop_services()
  end

  @spec seed([String.t()]) :: :ok
  def seed(_argv) do
    start_services()
    run_migrations()
    run_seeds()
    stop_services()
  end

  defp start_services do
    IO.puts("Loading #{@otp_app}..")
    :ok = Application.load(@otp_app)

    IO.puts("Starting dependencies..")
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts("Starting repos..")
    Enum.each(@repos, & &1.start_link(pool_size: 2))
  end

  defp stop_services do
    IO.puts("Success!")
    :init.stop()
  end

  defp run_migrations do
    Enum.each(@repos, &run_migrations_for/1)
  end

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running migrations for #{app}")
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  defp run_seeds do
    Enum.each(@repos, &run_seeds_for/1)
  end

  defp run_seeds_for(repo) do
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
end
