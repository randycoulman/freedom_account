defmodule FreedomAccount.MixProject do
  @moduledoc false

  use Mix.Project

  # credo:disable-for-this-file Credo.Check.Warning.MixEnv
  # Reason: Use of Mix.env() is perfectly valid in this file.

  @version "1.10.0"

  @spec project :: Keyword.t()
  def project do
    [
      aliases: aliases(),
      app: :freedom_account,
      compilers: [:phoenix_live_view, :boundary] ++ Mix.compilers(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: "config/dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_add_apps: [:ex_unit, :mix],
        plt_local_path: "priv/plts"
      ],
      elixir: "~> 1.15",
      elixirc_options: elixirc_options(Mix.env()),
      elixirc_paths: elixirc_paths(Mix.env()),
      listeners: [Phoenix.CodeReloader],
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

  @spec cli :: Keyword.t()
  def cli do
    [preferred_envs: [precommit: :test]]
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
      {:assertions, "~> 0.22.0", only: [:test]},
      {:bandit, "~> 1.8"},
      {:boundary, "~> 0.10.4"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dns_cluster, "~> 0.2.0"},
      {:ecto_sql, "~> 3.13"},
      {:esbuild, "~> 0.10.0", runtime: Mix.env() == :dev},
      {:ex_machina, "~> 2.8", only: :test},
      {:ex_money, "~> 5.23", runtime: false},
      {:ex_money_sql, "~> 1.11"},
      {:faker, "~> 0.18.0", only: :test},
      {:gettext, "~> 1.0"},
      {:heroicons,
       github: "tailwindlabs/heroicons", tag: "v2.2.0", sparse: "optimized", app: false, compile: false, depth: 1},
      {:jason, "~> 1.2"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:mix_test_interactive, "~> 5.0", only: :dev, runtime: false},
      {:nimble_csv, "~> 1.3"},
      {:paginator, "~> 1.2"},
      {:phoenix_ecto, "~> 4.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.8.7"},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_test, "~> 0.9.1", only: :test, runtime: false},
      {:phoenix, "~> 1.8"},
      # This is here to resolve a conflict with paginator's dependencies
      {:plug_crypto, "~> 2.1", override: true},
      {:postgrex, ">= 0.0.0"},
      {:process_tree, "~> 0.2.0"},
      {:styler, "~> 1.9", only: [:dev, :test], runtime: false},
      {:tailwind, "~> 0.4.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.1"},
      {:telemetry_poller, "~> 1.3"},
      {:typed_ecto_schema, "~> 0.4.3"},
      {:typed_struct, "~> 0.3.0"}
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
      "assets.build": ["compile", "tailwind freedom_account", "esbuild freedom_account"],
      "assets.deploy": [
        "tailwind freedom_account --minify",
        "esbuild freedom_account --minify",
        "phx.digest"
      ],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      build: ["cmd docker build -t freedom_account:#{@version} ."],
      dev: ["cmd docker compose up --build -d"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "credo", "dialyzer", "test"],
      prod: ["cmd docker compose up -d app"],
      "prod.debug": ["cmd docker compose up app"],
      s: ["phx.server"],
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      stop: ["cmd docker compose --profile prod down"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
