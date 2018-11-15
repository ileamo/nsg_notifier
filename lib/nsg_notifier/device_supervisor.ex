defmodule NsgNotifier.DeviceSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  def start_link(arg) do
    IO.puts("DS start link")
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    IO.puts("DS init")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      Supervisor.child_spec({NsgNotifier.Device, id}, id: id)
    )
  end
end
