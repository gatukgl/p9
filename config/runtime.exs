import Config

defmodule Util do
  def read_env(name, default) do
    case System.get_env(name) do
      x when x == "" or x == nil -> default
      x -> x
    end
  end
end

config :logger,
  level: :debug,
  compile_time_purge_matching: [[level_lower_than: :debug]]

config :nostrum,
  token: System.get_env("DISCORD_TOKEN"),
  num_shards: :auto

config :porcelain, driver: Porcelain.Driver.Basic

config :phoenix, json_library: Jason

config :p9, ecto_repos: [P9.Domain.Repo]

config :p9, P9.Domain.Repo,
  url: Util.read_env("DATABASE_URL", "postgres://p9:prodigy9@0.0.0.0:5432/p9?sslmode=disable")

config :p9, P9.Web.Endpoint,
  url: [host: "0.0.0.0"],
  http: [port: 4000],
  server: true
