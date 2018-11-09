defmodule NsgNotifier.SmsSender do
  use GenServer
  alias NsgNotifier.EventLogAgent

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:send, phone_list, deveui, text}, state) do
    Enum.map(phone_list, &send_sms(&1, deveui, text))
    {:noreply, state}
  end

  defp send_sms(phone, deveui, text) do
    smstext = "#{deveui}: #{text}"

    with {res, 0} <-
           System.cmd("smsshLTE", ["-p", "port.m1", "--phone", phone, "--sms", smstext]),
         true <- Regex.match?(~r/\s*OK\s*/, res) do
      IO.puts("SMS: #{phone}: #{smstext}")
      EventLogAgent.put(:info, deveui, "Послано СМС на номер #{phone}")
    else
      false ->
        IO.puts("SMS ERROR, rep")
        send_sms(phone, deveui, text)

      _ ->
        IO.puts("Bad exit code")
    end
  end

  ## client

  def send(params, phone_list, text) do
    GenServer.cast(__MODULE__, {:send, phone_list, params["deveui"], text})
    text
  end
end
