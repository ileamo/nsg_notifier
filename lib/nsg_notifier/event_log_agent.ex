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

  def put(:ok, _, _) do
  end

  def put(alert, deveui, mes) do
    message = "#{NsgNotifier.Aux.get_local_time()}: #{deveui}: #{mes}"
    put({alert, message})
    NsgNotifierWeb.Endpoint.broadcast!("room:lobby", "new_log", %{alert: alert, body: message})

    if deveui do
      case alert do
        a when a in [:danger, :warning] ->
          NsgNotifier.AlertAgent.put(alert, {deveui, mes}, true)

        _ ->
          NsgNotifier.AlertAgent.put(:danger, {deveui, mes})
          NsgNotifier.AlertAgent.put(:warning, {deveui, mes})
      end
    end
  end

  def get() do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
