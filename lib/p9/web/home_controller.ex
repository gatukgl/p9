defmodule P9.Web.HomeController do
  use Phoenix.Controller, namespace: P9.Web

  def index(conn, _params) do
    json(conn, %{alive: true})
  end
end
