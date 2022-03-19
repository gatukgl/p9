defmodule P9Chat.VoiceChan do
  use P9Chat.Responder

  alias Nostrum.Api

  require Protocol

  @rx ~r/\#(talking|coding|chilling|thinking|eating|gaming)/i
  @chan_maps %{
    talking: 809_290_566_365_609_995,
    coding: 832_984_927_489_228_850,
    chilling: 841_238_445_040_599_041,
    thinking: 859_063_153_845_731_338,
    eating: 859_063_236_066_410_526,
    gaming: 913_773_821_155_233_812
  }

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx)
  end

  @impl true
  def interact(msg) do
    Logger.info("voice channel mention detected")
    [_, chan] = Regex.run(@rx, msg.content)

    new_content = String.replace(msg.content, chan, "<##{@chan_maps[chan]}>")

    case Api.edit_message(msg, content: new_content) do
      {:ok, _} ->
        :ack

      {:error, err} ->
        reply(msg, error_msg(err))
        :error
    end
  end
end
