defmodule P9Chat.Deploy do
  use P9Chat.Responder

  require Protocol

  alias Nostrum.Api
  alias Nostrum.Struct.Overwrite

  @rx ~r/\s*deploy\s*\??(.+)/i

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx) &&
      Bot.is_bot_mention?(msg)
  end

  @impl true
  def interact(msg) do
    day = (Date.utc_today() |> Date.day_of_week()) - 1

    with {:ok, resp} <-
           Finch.build(:get, "https://deploydeemai.today/api?day=#{day}")
           |> Finch.request(P9Finch),
         {:ok, obj} <- Poison.decode(resp.body, keys: :atoms) do
      reply(msg, obj.message)
      :ack
    else
      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end
end
