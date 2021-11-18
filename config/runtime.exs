import Config

defmodule Env do
  def get(key) do
    v = System.get_env(key)
    if v == nil, do: "", else: String.trim(v)
  end

  def is_set?(key) do
    get(key) != ""
  end
end

# required, since we're primarily a discord bot
config :nostrum,
  token: Env.get("DISCORD_TOKEN")

if Env.is_set?("DATABASE_URL") do
  config :p9, P9.Repo, url: Env.get("DATABASE_URL")
end

if Env.is_set?("PORT") do
  config :p9, P9Web.Endpoint, http: [port: Env.get("PORT")]
end

if Env.is_set?("POSTMARK_TOKEN") do
  config :p9, P9Mailer,
    adapter: Swoosh.Adapters.Postmark,
    api_key: Env.get("POSTMARK_TOKEN")
end
