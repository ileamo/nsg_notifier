defmodule NsgNotifier.EventLogAgent do
  use Agent
  @max_items 50

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def put(item) do
    Agent.update(
      __MODULE__,
      fn state ->
        [item | state]
        |> Enum.take(@max_items)
      end
    )
  end

  def get() do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
