defmodule NsgNotifierWeb.PageController do
  use NsgNotifierWeb, :controller
  alias NsgNotifier.AlertAgent

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def delete(conn, params = %{"alert" => alert, "id" => id}) do
    IO.puts("DELETE")
    IO.inspect(params)
    AlertAgent.delete(String.to_existing_atom(alert), id)
    render(conn, "index.html")
  end
end
