defmodule NsgNotifier.Device do
  use GenServer
  require Logger
  alias NsgNotifier.LwsApi
  alias NsgNotifier.EventLogAgent
  alias NsgNotifier.Handler

  @tmo 60 * 60 * 1000

  def start_link(id) do
    GenServer.start_link(__MODULE__, %{id: id}, name: {:global, id})
  end

  ## Callbacks

  @impl true
  def init(state) do
    Process.send_after(self(), :idle_timeout, @tmo)

    {:ok, state |> get_device() |> get_last_rx()}
  end

  defp get_device(state) do
    device =
      case LwsApi.get("/api/devices/" <> state.id) do
        {:ok, device} ->
          device

        _ ->
          Logger.warn("Can't get device info(deveui=#{state.id})")
          %{}
      end

    state |> Map.put(:device, device)
  end

  defp get_last_rx(state) do
    timestamp =
      with node_id when node_id != nil <- state[:device]["node"],
           {:ok, node} <- LwsApi.get("/api/nodes/" <> node_id),
           last_rx when last_rx != nil <- node["last_rx"],
           {:ok, dt, _} <- last_rx |> DateTime.from_iso8601() do
        DateTime.to_unix(dt)
      else
        res ->
          Logger.warn("Can't get device last_rx(deveui=#{state.id}) #{inspect(res)}")
          :os.system_time(:second)
      end

    state |> Map.put(:event_list, [{timestamp, %{}}])
  end

  @impl true
  def handle_cast({:put_event, event}, state) do
    state = (state.device["deveui"] && state) || get_device(state)

    {_, state} =
      state
      |> Map.get_and_update(:event_list, fn l ->
        {l, [{:os.system_time(:second), event} | l]}
      end)

    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    check_activity(state)
    Process.send_after(self(), :idle_timeout, @tmo)

    {:noreply, state}
  end

  @impl true
  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  defp check_activity(%{id: id, event_list: [{timestamp, _} | _]}) do
    Task.start(fn ->
      {alert, message} =
        Handler.handle(%{"deveui" => id, :inactivity => :os.system_time(:second) - timestamp})

      EventLogAgent.put(alert, id, message)
    end)
  end

  defp check_activity(device) do
    Logger.error("check_activity: #{inspect(device)}")
  end

  # client

  def get(id) do
    GenServer.call({:global, id}, {:get})
  end

  def put_event(id, event) do
    GenServer.cast({:global, id}, {:put_event, event})
  end
end
