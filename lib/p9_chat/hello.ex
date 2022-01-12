defmodule P9Chat.Hello do
  use P9Chat.Responder

  @rx ~r/^(<@!?\d+>)\s*hello\s*/i

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx) &&
      Bot.is_bot_mention?(msg)
  end

  @impl true
  def interact(msg) do
    reply(
      msg,
      "A STRANGE GAME.\n" <>
        "THE ONLY WINNING MOVE IS\n" <>
        "NOT TO PLAY."
    )
  end
end
