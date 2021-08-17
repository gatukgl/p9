defmodule P9Chat.Search do
  use P9Chat.Responder

  alias P9.Knowledge

  @rx ~r/^(<@!?\d+>)\s+search(\s+for)?\s+(.+)\s*/i

  @impl true
  def match(msg), do: String.match?(msg.content, @rx)

  @impl true
  def interact(msg) do
    Logger.info("searching for knowledges")
    [_, _, _, query] = Regex.run(@rx, msg.content)

    case Knowledge.search(query) do
      x when x in [nil, []] ->
        reply(msg, dontknow_msg(query))
        :ack

      result ->
        reply(msg, result_msg(query, result))
        :ack
    end
  end
end
