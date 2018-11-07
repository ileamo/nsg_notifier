defmodule NsgNotifierWeb.Api.EventController do
  use NsgNotifierWeb, :controller

  alias NsgNotifier.Handler
  alias NsgNotifier.EventLogAgent

  def index(conn, args) do
    IO.puts("***API***")
    IO.inspect(args)

    {alert, message} = Handler.handle(args)
    EventLogAgent.put(alert, args["deveui"], message)

    send_resp(conn, 200, "")
  end
end
