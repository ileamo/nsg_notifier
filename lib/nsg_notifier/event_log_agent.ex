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

  def put(alert, deveui, message) do
    message = "#{NsgNotifier.Aux.get_local_time()}: #{deveui}: #{message}"
    put({alert, message})
    NsgNotifierWeb.Endpoint.broadcast!("room:lobby", "new_msg", %{alert: alert, body: message})
  end

  def get() do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
