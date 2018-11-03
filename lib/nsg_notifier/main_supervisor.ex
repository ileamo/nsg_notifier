defmodule NsgNotifier.MainSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      NsgNotifier.Conf
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
