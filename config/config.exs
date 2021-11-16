import Config

config :logger,
  level: :debug,
  compile_time_purge_matching: [[level_lower_than: :debug]]

config :porcelain,
  driver: Porcelain.Driver.Basic

config :phoenix,
  json_library: Jason

config :nostrum,
  num_shareds: :auto

config :p9,
  ecto_repos: [P9.Repo]

config :p9, P9.Repo, url: "postgres://0.0.0.0:5432/p9?sslmode=disable"

config :p9, P9Web.Endpoint,
  url: [host: "0.0.0.0"],
  http: [port: 4000],
  server: true

config :p9, P9.Mailer,
  adapter: Swoosh.Adapters.Postmark,
  api_key: ""
