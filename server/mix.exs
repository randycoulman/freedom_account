defmodule FreedomAccount.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :freedom_account,
      compilers: [:gettext] ++ Mix.compilers(),
      default_release: :freedom_account,
      deps: deps(),
      dialyzer: [
        ignore_warnings: "config/dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_add_apps: [:ex_unit]
      ],
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      releases: [
        freedom_account: [
          include_executables_for: [:unix]
        ]
      ],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.1.0"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FreedomAccount.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:absinthe, "~> 1.6"},
      {:absinthe_plug, "~> 1.5"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ecto_psql_extras, "~> 0.7"},
      {:ecto_sql, "~> 3.7"},
      {:ex_machina, "~> 2.7", only: :test},
      {:excoveralls, "~> 0.14.2", only: :test},
      {:faker, "~> 0.16.0", only: :test},
      {:gettext, "~> 0.18.2"},
      {:hammox, "~> 0.5.0", only: :test},
      {:jason, "~> 1.0"},
      {:junit_formatter, "~> 3.3", only: [:test]},
      {:knigge, "~> 1.4"},
      {:mix_test_interactive, "~> 1.1", only: :dev, runtime: false},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:phoenix, "~> 1.6"},
      {:plug_cowboy, "~> 2.5.2"},
      {:plug_static_index_html, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      s: [
        "ecto.setup",
        "cmd scripts/zombie-killer.sh elixir --sname server -S mix phx.server"
      ],
      setup: ["deps.get", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      validate: [
        "cmd MIX_ENV=test mix coveralls.html",
        "format --check-formatted",
        "credo",
        "dialyzer"
      ]
    ]
  end
end
