defmodule NsgNotifierWeb.Api.EventController do
  use NsgNotifierWeb, :controller

  alias NsgNotifier.Handler
  alias NsgNotifier.EventLogAgent

  def index(conn, args) do
    IO.puts("***API***")
    IO.inspect(args)

    Handler.handle(args)
    |> EventLogAgent.put()

    send_resp(conn, 200, "")
  end
end
