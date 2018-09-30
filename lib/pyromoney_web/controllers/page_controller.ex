defmodule PyromoneyWeb.PageController do
  use PyromoneyWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
