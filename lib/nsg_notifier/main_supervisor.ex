defmodule NsgNotifier.MainSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    children = [
      NsgNotifier.Conf,
      NsgNotifier.EventLogAgent,
      Supervisor.child_spec({NsgNotifier.AlertAgent, :danger}, id: :danger),
      Supervisor.child_spec({NsgNotifier.AlertAgent, :warning}, id: :warning),
      NsgNotifier.SmsSender,
      NsgNotifier.DeviceSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
