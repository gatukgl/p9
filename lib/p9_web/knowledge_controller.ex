defmodule P9Web.KnowledgeController do
  use Phoenix.Controller, namespace: P9Web

  alias P9.Knowledge

  def index(conn, _params) do
    json(conn, Knowledge.get_all())
  end
end
