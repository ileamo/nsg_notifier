defmodule NsgNotifier.UI do
  defdelegate(sms(event, phone_list, message), to: NsgNotifier.SmsSender, as: :send)
  defdelegate(email(event, address_list, message), to: NsgNotifier.EmailSender, as: :email)
end
