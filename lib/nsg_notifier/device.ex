defmodule NsgNotifier.Device do
  use GenServer
  alias NsgNotifier.LwsApi
  alias NsgNotifier.EventLogAgent
  alias NsgNotifier.Handler

  @tmo 1 * 10 * 1000

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

    {:ok, state |> Map.put(:device, device), @tmo}
  end

  @impl true
  def handle_cast({:put_event, event}, state) do
    {_, state} =
      state
      |> Map.get_and_update(:event_list, fn l ->
        {l, [{:os.system_time(:second), event} | l]}
      end)

    {:noreply, state, @tmo}
  end

  @impl true
  def handle_info(_msg, state) do
    Task.start(fn ->
      check_activity(state)
    end)

    {:noreply, state, @tmo}
  end

  @impl true
  def handle_call({:get}, _from, state) do
    {:reply, state, state, @tmo}
  end

  defp check_activity(%{id: id, event_list: [{timestamp, _} | _]}) do
    {alert, message} =
      Handler.handle(%{"deveui" => id, "inactivity" => :os.system_time(:second) - timestamp})

    EventLogAgent.put(alert, id, message)
  end

  defp check_activity(_) do
    IO.puts("No activity")
  end

  # client

  def get(id) do
    GenServer.call({:global, id}, {:get})
  end

  def put_event(id, event) do
    GenServer.cast({:global, id}, {:put_event, event})
  end
end
