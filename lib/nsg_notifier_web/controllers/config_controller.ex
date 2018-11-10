defmodule NsgNotifierWeb.ConfigController do
  use NsgNotifierWeb, :controller

  def edit(conn, _) do
    render(conn, "edit.html")
  end

  def update(conn, _) do
    render(conn, "edit.html")
  end
end
