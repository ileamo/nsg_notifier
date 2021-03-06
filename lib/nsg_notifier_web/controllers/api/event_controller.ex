defmodule NsgNotifierWeb.Api.EventController do
  use NsgNotifierWeb, :controller

  alias NsgNotifier.Handler
  alias NsgNotifier.EventLogAgent
  alias NsgNotifier.DeviceSupervisor
  alias NsgNotifier.Device

  def index(conn, args = %{"deveui" => id}) do
    DeviceSupervisor.start_child(id)
    Device.put_event(id, args)
    {alert, message} = Handler.handle(args)
    EventLogAgent.put(alert, id, message)
    send_resp(conn, 200, "")
  end

  def index(conn, _args) do
    EventLogAgent.put(:info, "<NO DEVEUI>", "Bad event")
    send_resp(conn, 200, "")
  end
end
