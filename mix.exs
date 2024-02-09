defmodule FreedomAccount.MixProject do
  @moduledoc false

  use Mix.Project

  # credo:disable-for-this-file Credo.Check.Warning.MixEnv
  # Reason: Use of Mix.env() is perfectly valid in this file.

  @version "0.1.0"

  @spec project :: Keyword.t()
  def project do
    [
      aliases: aliases(),
      app: :freedom_account,
      deps: deps(),
      dialyzer: [
        ignore_warnings: "config/dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_add_apps: [:ex_unit]
      ],
      elixir: "~> 1.14",
      elixirc_options: elixirc_options(Mix.env()),
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [validate: :test],
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  @spec application :: Keyword.t()
  def application do
    [
      mod: {FreedomAccount.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_options(:dev) do
    [
      all_warnings: true,
      ignore_module_conflict: true,
      warnings_as_errors: false
    ]
  end

  defp elixirc_options(:test) do
    [
      all_warnings: true,
      warnings_as_errors: false
    ]
  end

  defp elixirc_options(_) do
    [
      all_warnings: true,
      warnings_as_errors: true
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.11"},
      {:esbuild, "~> 0.8.1", runtime: Mix.env() == :dev},
      {:faker, "~> 0.17", only: :test},
      {:floki, ">= 0.30.0", only: :test},
      {:gettext, "~> 0.20"},
      {:heroicons, "~> 0.5.3"},
      {:jason, "~> 1.2"},
      {:junit_formatter, "~> 3.3", only: [:test]},
      {:mix_test_interactive, "~> 2.0", only: :dev, runtime: false},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.5"},
      {:phoenix, "~> 1.7"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6.2"},
      {:telemetry_poller, "~> 1.0"},
      {:typed_ecto_schema, "~> 0.4.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      build: ["cmd docker build -t freedom_account:#{@version} ."],
      dev: ["cmd docker compose up --build -d"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      prod: ["cmd docker compose up -d app"],
      "prod.debug": ["cmd docker compose up app"],
      s: ["phx.server"],
      setup: ["deps.get", "ecto.setup"],
      stop: ["cmd docker compose --profile prod down"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      validate: [
        "format --check-formatted",
        "credo",
        "dialyzer",
        "test"
      ]
    ]
  end
end
