defmodule NsgNotifierWeb.LwsconfigController do
  use NsgNotifierWeb, :controller
  alias NsgNotifier.Conf
  alias NsgNotifier.LwsApi

  def edit(conn, _) do
    render(conn, "edit.html", %{
      lwsconfig: Conf.get(:lwsconfig) || %{"url" => "http://127.0.0.1:8080"}
    })
  end

  def update(conn, _args = %{"lwsconfig" => lwsconfig}) do
    Conf.put(:lwsconfig, lwsconfig)

    case LwsApi.get("/api/config/main") do
      {:ok, _} ->
        redirect(conn, to: page_path(conn, :index))

      {:error, reason} ->
        error_handler(conn, reason, lwsconfig)

      reason ->
        error_handler(conn, reason, lwsconfig)
    end
  end

  defp error_handler(conn, reason, lwsconfig) do
    conn
    |> put_flash(:error, "Ошибка обращения к серверу: #{reason}")
    |> render("edit.html", %{lwsconfig: lwsconfig})
  end
end
