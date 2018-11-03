defmodule NsgNotifier.Conf do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks

  @impl true
  def init(_param) do
    load_conf()
    {:ok, :ok}
  end

  @path "priv/var/"
  @name "conf.ex"

  defp load_conf() do
    case File.exists?(@path <> @name) do
      true -> Code.compile_file(@name, @path)
      _ -> IO.puts("no config file")
    end
  end
end
