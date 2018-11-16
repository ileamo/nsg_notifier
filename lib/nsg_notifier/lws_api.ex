defmodule NsgNotifier.LwsApi do
  def get(path) do
    lwsconfig = NsgNotifier.Conf.get(:lwsconfig) || %{"url" => "http://localhost:8080"}
    url = lwsconfig["url"] <> path
    username = lwsconfig["username"]
    password = lwsconfig["password"]

    with {:ok, %HTTPoison.Response{body: _, headers: headers, status_code: 401}} <-
           HTTPoison.get(url),
         authorization <-
           Httpdigest.create_header(
             headers,
             username,
             password,
             "GET",
             path
           ),
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
