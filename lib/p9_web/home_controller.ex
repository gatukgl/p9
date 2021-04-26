defmodule P9Web.HomeController do
  use Phoenix.Controller, namespace: P9Web

  def index(conn, _params) do
    json(conn, %{alive: true})
  end
end
