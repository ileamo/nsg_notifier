defmodule NsgNotifier.UI do
  defdelegate(send_sms(event, phone_list, message), to: NsgNotifier.SmsSender, as: :send)
end
