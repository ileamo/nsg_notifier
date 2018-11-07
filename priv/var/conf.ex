defmodule NsgNotifier.Handler do
  def handle(event) do
    case event do
      %{"event" => "joined"} ->
        {:info, "Датчик авторизовался"}

      #
      # SI-11
      #
      %{"type" => "1"} ->
        {:success, "Спасибо что живой"}

      %{"type" => "2", "door" => door} ->
        mes = "Вскрыта дверь #{door}"
        NsgNotifier.SmsSender.send(event, ["+79031882422", "+79030199081"], mes)
        {:danger, mes}

      #
      # Gas detector
      #
      %{"alarm" => 2} ->
        {:danger, "Утечка газа"}

      %{"button" => 1} ->
        {:info, "Тест"}

      %{"alarm" => 0} ->
        {:success, "Живой"}

      #
      # other
      #
      _ ->
        {:warning, "Unknown event #{inspect(event)}"}
    end
  end
end
