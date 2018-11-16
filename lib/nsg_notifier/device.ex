defmodule NsgNotifier.Device do
  use GenServer
  alias NsgNotifier.LwsApi

  def start_link(id) do
    GenServer.start_link(__MODULE__, %{id: id, event_list: []}, name: {:global, id})
  end

  ## Callbacks

  @impl true
  def init(state) do
    device =
      case LwsApi.get("/api/devices/" <> state.id) do
        {:ok, device} -> device
        _ -> %{}
      end

    {:ok, state |> Map.put(:device, device)}
  end

  @impl true
  def handle_cast({:put_event, event}, state) do
    {_, state} =
      state
      |> Map.get_and_update(:event_list, fn l ->
        {l, [{:os.system_time(:second), event} | l]}
      end)

    {:noreply, state}
  end

  @impl true
  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  # client

  def get(id) do
    GenServer.call({:global, id}, {:get})
  end

  def put_event(id, event) do
    GenServer.cast({:global, id}, {:put_event, event})
  end
end
