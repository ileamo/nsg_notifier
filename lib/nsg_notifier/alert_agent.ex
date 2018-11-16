defmodule NsgNotifier.AlertAgent do
  use Agent
  alias NsgNotifier.Device

  def start_link(name) do
    Agent.start_link(fn -> [] end, name: name)
  end

  def put(name, {id, mes}, new \\ false) do
    Agent.update(
      name,
      fn state ->
        mes = "#{NsgNotifier.Aux.get_local_time()}: #{mes}"

        with {{id, info, mes_list}, item_list} <- List.keytake(state, id, 0) do
          broadcast(name)
          [{id, info, mes_list ++ [mes]} | item_list]
        else
          _ when new ->
            %{device: device} = Device.get(id)
            info = device["desc"] || "Нет описания"
            broadcast(name)
            [{id, info, [mes]} | state]

          _ ->
            state
        end
      end
    )
  end

  defp broadcast(name) do
    NsgNotifierWeb.Endpoint.broadcast!("room:lobby", "new_alert", %{alert: name})
  end

  def get(name) do
    Agent.get(name, fn state -> state end)
  end

  def delete(name, id) do
    Agent.update(
      name,
      fn state ->
        List.keydelete(state, id, 0)
      end
    )
  end
end
