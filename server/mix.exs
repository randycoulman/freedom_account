defmodule FreedomAccount.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :freedom_account,
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: "config/dialyzer_ignore.exs",
        list_unused_filters: true,
        plt_add_apps: [:ex_unit],
        plt_core_path: "_plts",
        plt_file: {:no_warn, "_plts/dialyzer-#{Mix.env()}.plt"}
      ],
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
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
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:distillery, "~> 2.0"},
      {:ecto_sql, "~> 3.0"},
      {:excoveralls, "~> 0.10.0", only: :test},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:mix_test_watch, "~> 0.9", only: [:dev, :test], runtime: false},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix, "~> 1.4"},
      {:plug_cowboy, "~> 2.0"},
      {:plug_static_index_html, "~> 1.0"},
      {:postgrex, ">= 0.0.0"}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      validate: [
        "cmd MIX_ENV=test mix coveralls.html",
        "format --check-formatted",
        "credo",
        "dialyzer --format short --halt-exit-status"
      ]
    ]
  end
end
