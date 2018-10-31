defmodule NsgNotifierWeb.PageController do
  use NsgNotifierWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
