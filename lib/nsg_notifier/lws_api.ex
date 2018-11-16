defmodule NsgNotifier.LwsApi do
  def get(url) do
    with {:ok, %HTTPoison.Response{body: _, headers: headers, status_code: 401}} <-
           HTTPoison.get(url),
         authorization <-
           Httpdigest.create_header(headers, "admin", "admin", "GET", URI.parse(url).path || "/"),
         {:ok, %HTTPoison.Response{body: body, status_code: 200}} <-
           HTTPoison.get(url, authorization),
         {:ok, body} <- Poison.decode(body) do
      {:ok, body}
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Bad status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "request error: #{inspect(reason)}"}

      {:error, reason} ->
        {:error, "ERROR: #{inspect(reason)}"}

      res ->
        {:error, "FATAL: #{inspect(res)}"}
    end
  end
end
