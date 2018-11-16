defmodule NsgNotifierWeb.LwsconfigController do
  use NsgNotifierWeb, :controller
  alias NsgNotifier.Conf

  def edit(conn, _) do
    render(conn, "edit.html", %{lwsconfig: Conf.get(:lwsconfig)})
  end

  def update(conn, _args = %{"lwsconfig" => lwsconfig}) do
    Conf.put(:lwsconfig, lwsconfig)
    redirect(conn, to: page_path(conn, :index))
  end
end
