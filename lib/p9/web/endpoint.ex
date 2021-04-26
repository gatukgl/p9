defmodule P9.Web.Endpoint do
  use Phoenix.Endpoint,
    otp_app: :p9

  plug(P9.Web.Router)
end
