defmodule NsgNotifierWeb.ConfigController do
  use NsgNotifierWeb, :controller
  alias NsgNotifier.Conf

  def edit(conn, _) do
    render(conn, "edit.html", %{conf_ex: Conf.get_conf_ex()})
  end

  def update(conn, _args = %{"config" => %{"conf_ex" => conf_ex}}) do
    case Conf.put_conf_ex(conf_ex) do
      {:error, mes} ->
        conn
        |> put_flash(:error, "Ошибка в файле конфигурации: #{mes}")
        |> render("edit.html", %{conf_ex: conf_ex})

      _ ->
        redirect(conn, to: page_path(conn, :index))
    end
  end
end
