defmodule NsgNotifier.DeviceSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor
  alias NsgNotifier.Device

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    res = DynamicSupervisor.init(strategy: :one_for_one)
    Task.start(fn -> get_all_devices() end)
    res
  end

  def start_child(id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      Supervisor.child_spec({Device, id}, id: id)
    )
  end

  def get_all_devices() do
    with {:ok, node_list} <- NsgNotifier.LwsApi.get("/api/nodes"),
         devaddr_list <-
           node_list
           |> Enum.map(fn
             %{"devaddr" => d} -> d
             _ -> nil
           end),
         {:ok, device_list} <- NsgNotifier.LwsApi.get("/api/devices") do
      device_list
      |> Enum.each(fn device ->
        if(device["node"] in devaddr_list) do
          start_child(device["deveui"])
        end
      end)
    end
  end
end
