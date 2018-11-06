defmodule NsgNotifier.Handler do
  def handle(event) do
    case event do
      %{"event" => "joined"} -> {:info, "Датчик авторизовался"}
      #
      # SI-11
      #
      %{"type" => "1"} -> {:success, "Спасибо что живой"}
      %{"type" => "2", "door" => door} -> {:danger, "Вскрыта дверь #{door}"}
      #
      # Gas detector
      #
      %{"alarm" => 2} -> {:danger, "Утечка газа"}
      %{"button" => 1} -> {:info, "Тест"}
      %{"alarm" => 0} -> {:success, "Живой"}
      #
      # other
      #
      _ -> {:warning, "Unknown event #{inspect(event)}"}
    end
  end
end
