defmodule P9.Web.Router do
  use Phoenix.Router, namespace: P9.Web

  get("/", P9.Web.HomeController, :index)
end
