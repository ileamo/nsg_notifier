defmodule NsgNotifier.SmsSender do
  use GenServer
  require Logger
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

  defp send_sms(phone, deveui, text, attempt \\ 3) do
    smstext = "#{deveui}: #{text}"

    with {res, 0} <-
           System.cmd("smsshLTE", ["-p", "port.m1", "--phone", phone, "--sms", smstext]),
         true <- Regex.match?(~r/\s*OK\s*/, res) do
      IO.puts("SMS: #{phone}: #{smstext}")
      EventLogAgent.put(:secondary, deveui, "Послано СМС на номер #{phone}")
    else
      false ->
        Logger.warn("Error sending SMS to #{phone}")

        if attempt > 1 do
          send_sms(phone, deveui, text, attempt - 1)
        end

      _ ->
        Logger.warn("smsshLTE: Bad exit code")
    end
  end

  ## client

  def send(params, phone_list, text) do
    GenServer.cast(__MODULE__, {:send, phone_list, params["deveui"], text})
    text
  end
end
