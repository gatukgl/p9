defmodule P9.Web.ErrorView do
  def render("404.html", _assigns) do
    Jason.encode!(%{error: :not_found})
  end
end
