defmodule NsgNotifier.EmailSender do
  alias NsgNotifier.EventLogAgent

  def email(%{"deveui" => id}, reciver_list, text) do
    :gen_smtp_client.send(
      {"ileamo@yandex.ru", reciver_list,
       "Content-Type: text/plain; charset=utf-8\r\n" <>
         "Subject: Предупреждение\r\n" <>
         "From: NSG LoRa<noreply@nsg.net.ru>\r\n" <>
         "To: #{reciver_list |> Enum.join(",")}\r\n\r\n" <> "Датчик #{id}\r\n#{text}"},
      [
        relay: "smtp.yandex.ru",
        username: "ileamo",
        password: "ym023706",
        auth: "always",
        tls: "always",
        ssl: true
      ],
      fn
        {:ok, _res} ->
          EventLogAgent.put(
            :info,
            id,
            "Отправлено письмо на email #{reciver_list |> Enum.join(", ")}"
          )

        res ->
          IO.inspect(res)
      end
    )

    text
  end
end
