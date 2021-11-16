defmodule P9.DiscordEmail do
  import Swoosh.Email

  @spec single_invitation(String.t(), String.t()) :: Swoosh.Email.t()
  def single_invitation(email, invite_code) do
    link = "https://discord.gg/#{invite_code}"

    new()
    |> to(email)
    |> from({"PRODIGY9 Robot", "robot@prodigy9.co"})
    |> subject("PRODIGY9 Discord Invitation")
    |> html_body("""
    <h3>Hello, Friends of PRODIGY9</h3>
    <p>This is a <strong>Single-Use Invitation Link</strong>, click the following to join:</p>
    <p><a href="#{link}">#{link}</a></p>
    <p>Once you've joined the Discord, ask someone to give you a role.<p>
    """)
    |> text_body("""
    ### Hello, Friends of PRODIGY9

    This is a **Single-Use Invitation Link**, click the following to join:

    #{link}

    Once you've joined the Discord, ask someone to give you a role.
    """)
  end
end
