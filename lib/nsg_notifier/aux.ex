defmodule NsgNotifier.Aux do
  def get_local_time() do
    {_, {h, m, s}} = :calendar.local_time()
    :io_lib.format("~2..0B:~2..0B:~2..0B", [h, m, s])
  end
end
