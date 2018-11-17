defmodule NsgNotifierWeb.TestapiController do
  use NsgNotifierWeb, :controller
  alias NsgNotifier.Conf

  def edit(conn, _) do
    render(conn, "edit.html", %{
      testapi: Conf.get(:testapi) || %{"event" => ~s/{"deveui":"0123456789ABCDEF"}/}
    })
  end

  def update(conn, _args = %{"testapi" => testapi = %{"event" => event}}) do
    IO.inspect(event)
    IO.inspect(Poison.decode(event))

    case Poison.decode(event) do
      {:ok, _} ->
        Conf.put(:testapi, testapi)
        HTTPoison.post("http://localhost:4000/api", event, [{"Content-Type", "application/json"}])

        redirect(conn, to: page_path(conn, :index))

      res ->
        conn
        |> put_flash(:error, "Ошибка JSON: #{inspect(res)}")
        |> render("edit.html", %{testapi: testapi})
    end
  end
end
