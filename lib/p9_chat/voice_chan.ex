defmodule P9Chat.VoiceChan do
  use P9Chat.Responder

  require Protocol

  @rx ~r/\#(talking|coding|chilling|thinking|eating|gaming)/i
  @chan_maps %{
    "talking" => 809_290_566_365_609_995,
    "coding" => 832_984_927_489_228_850,
    "chilling" => 841_238_445_040_599_041,
    "thinking" => 859_063_153_845_731_338,
    "eating" => 859_063_236_066_410_526,
    "gaming" => 913_773_821_155_233_812,
    "mars" => 846_951_991_037_132_830,
    "venus" => 943_067_765_969_936_384
  }

  @impl true
  def match(msg) do
    String.match?(msg.content, @rx)
  end

  @impl true
  def interact(msg) do
    Logger.info("voice channel mention detected")
    [_, chan] = Regex.run(@rx, msg.content)
    reply(msg, "<##{@chan_maps[chan]}>")
    :ack
  end
end
