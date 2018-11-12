defmodule NsgNotifier.Conf do
  use GenServer
  alias :dets, as: Dets

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks

  @impl true
  def init(_param) do
    load_conf()
    {:ok, :ok}
  end

  @table :nnconf
  @ets_dir 'priv/'
  @ets_file @ets_dir ++ 'conf.ets'

  defp load_conf() do
    File.mkdir_p!(@ets_dir)
    get_conf_ex() |> put_conf_ex()
  end

  def get(param) do
    Dets.open_file(@table, file: @ets_file)

    case Dets.lookup(@table, param) do
      [{^param, value}] -> value
      _ -> nil
    end
  end

  def get_conf_ex() do
    case get(:conf_ex) do
      nil -> get_conf_ex_pattern()
      value -> value
    end
  end

  def put_conf_ex(conf) do
    try do
      Code.compile_string(conf, "conf")
      conf = conf |> Code.format_string!() |> IO.iodata_to_binary()
      open_conf()
      Dets.insert(@table, {:conf_ex, conf})
      close_conf()
      {:ok}
    rescue
      value -> {:error, inspect(value)}
    end
  end

  defp open_conf() do
    Dets.open_file(@table, file: @ets_file)
  end

  defp close_conf() do
    Dets.close(@table)
  end

  defp get_conf_ex_pattern() do
    """
    defmodule NsgNotifier.Handler do
      import NsgNotifier.UI

      def handle(args) do
        case args do
          %{"event" => "joined"} ->
            {:info, "Датчик авторизовался"}

          #
          # Добавьте здесь свои обработчки. Например:
          #
          # %{"alarm" => "2"} ->
          #   sms(args, ["+79991234567", "+79990987654"], "Gas detected")
          #   email(args, ["user@yandex.ru", "client@mail.ru"], "Произошла утечка газа")
          #   {:danger, "Утечка газа"}
          #

          _ ->
            {:warning, "Unknown event \#{inspect(args)}"}
        end
      end
    end
    """
  end
end
