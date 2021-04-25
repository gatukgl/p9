defmodule P9.DiscordInteractions do
  require Logger
  require Regex

  alias Nostrum.Api

  @hello_rx ~r{(<@\d+>)\s*hello\s*}

  def with(msg) do
    cond do
      Regex.run(@hello_rx, msg.content) ->
        Logger.info("greetings received")
        Api.create_message(msg.channel_id,
          "A STRANGE GAME.\n" <>
            "THE ONLY WINNING MOVE IS\n" <>
              "NOT TO PLAY.")

      true ->
        {:ignore, []}
    end
  end
end
