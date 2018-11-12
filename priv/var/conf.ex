defmodule NsgNotifier.Handler do
  import NsgNotifier.UI

  def handle(args) do
    case args do
      %{"event" => "joined"} ->
        {:info, "Датчик авторизовался"}

      #
      # SI-11
      #
      %{"type" => "1"} ->
        {:success, "В работе"}

      %{"type" => "2", "door" => door} ->
        {:danger, sms(args, ["+79031882422", "+79030199081"], "Вскрыта дверь #{door}")}

      #
      # Gas detector
      #
      %{"alarm" => "2"} ->
        sms(args, ["+79031882422", "+79030199081"], "Gas detected")
        email(args, ["ileamo@yandex.ru", "imo59y@yandex.ru"], "Произошла утечка газа")

        {:danger, "Утечка газа"}

      %{"button" => "1"} ->
        {:info, "Тест"}

      %{"alarm" => "0"} ->
        {:success, "  В работе"}

      #
      # other
      #
      _ ->
        {:warning, "Unknown event #{inspect(args)}"}
    end
  end
end
