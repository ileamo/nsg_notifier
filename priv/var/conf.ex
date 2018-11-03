defmodule NsgNotifier.Handler do
  def gas(%{"alarm" => 2}) do
    {:danger, "Gas detected"}
  end

  def gas(%{"button" => 1}) do
    {:info, "Test"}
  end

  def gas(%{"alarm" => 0}) do
    {:success, "Alive"}
  end

  def gas(event) do
    {:warning, "Unknown event #{inspect(event)}"}
  end
end
