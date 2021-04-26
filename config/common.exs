import Config

config :logger,
  level: :debug,
  compile_time_purge_matching: [[level_lower_than: :debug]]

config :nostrum,
  token: System.get_env("DISCORD_TOKEN"),
  num_shards: :auto

config :porcelain,
  driver: Porcelain.Driver.Basic
