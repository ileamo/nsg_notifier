defmodule NsgNotifier.Handler do
  import NsgNotifier.UI

  def handle(event) do
    case event do
      %{"event" => "joined"} ->
        {:info, "Датчик авторизовался"}

      #
      # SI-11
      #
      %{"type" => "1"} ->
        {:success, "В работе"}

      %{"type" => "2", "door" => door} ->
        {:danger, send_sms(event, ["+79031882422", "+79030199081"], "Вскрыта дверь #{door}")}

      #
      # Gas detector
      #
      %{"alarm" => "2"} ->
        send_sms(event, ["+79031882422", "+79030199081"], "Gas detected")
        email(event, ["ileamo@yandex.ru", "imo59y@yandex.ru"], "Произошла утечка газа")

        {:danger, "Утечка газа"}

      %{"button" => "1"} ->
        {:info, "Тест"}

      %{"alarm" => "0"} ->
        {:success, "  В работе"}

      #
      # other
      #
      _ ->
        {:warning, "Unknown event #{inspect(event)}"}
    end
  end
end
