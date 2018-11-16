defmodule NsgNotifierWeb.LwsconfigController do
  use NsgNotifierWeb, :controller

  def edit(conn, _) do
    render(conn, "edit.html", %{lwsconfig: NsgNotifier.Conf.get(:lwsconfig)})
  end

  def update(conn, _args = %{"lwsconfig" => lwsconfig}) do
    NsgNotifier.Conf.put(:lwsconfig, lwsconfig)
    redirect(conn, to: page_path(conn, :index))
  end
end
