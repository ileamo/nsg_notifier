defmodule NsgNotifierWeb.Api.EventController do
  use NsgNotifierWeb, :controller

  alias NsgNotifier.Handler
  alias NsgNotifier.EventLogAgent

  def index(conn, args) do
    IO.puts("***API***")
    IO.inspect(args)

    res = {alert, message} = Handler.handle(args)
    EventLogAgent.put(res)
    NsgNotifierWeb.Endpoint.broadcast!("room:lobby", "new_msg", %{alert: alert, body: message})
    send_resp(conn, 200, "")
  end
end
