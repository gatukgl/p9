defmodule P9Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :p9

  plug(P9Web.Router)
end
