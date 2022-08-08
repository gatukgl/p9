defmodule P9.MixProject do
  use Mix.Project

  def project do
    [
      app: :p9,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {P9, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowlib, "~> 2.10", override: true},
      {:ecto_sql, "~> 3.7"},
      {:finch, "~> 0.13"},
      {:hackney, "~> 1.18"},
      {:jason, "~> 1.0"},
      {:nostrum, "~> 0.5"},
      {:phoenix, "~> 1.6"},
      {:plug_cowboy, "~> 2.5"},
      {:poison, "~> 5.0"},
      {:porcelain, "~> 2.0"},
      {:postgrex, "~> 0.15"},
      {:swoosh, "~> 1.6.3"}
    ]
  end
end
