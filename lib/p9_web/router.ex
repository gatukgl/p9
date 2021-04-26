defmodule P9Web.Router do
  require Logger

  use Phoenix.Router, namespace: P9Web
  use Plug.ErrorHandler

  get("/", P9Web.HomeController, :index)
  get("/knowledges", P9Web.KnowledgeController, :index)

  defp handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{}}) do
    conn |> json(%{error: :not_found}) |> halt()
  end

  defp handle_errors(conn, err) do
    Logger.error("unknown error: #{Kernel.inspect(err)}")
    conn |> json(%{error: :unknown}) |> halt()
  end
end
