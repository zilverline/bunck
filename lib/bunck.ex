defmodule Bunck do
  @moduledoc """
  Documentation for Bunck.
  """

  @doc """
  Example:
    client = %Bunck.Client{...}
    %Bunck.Installation.Post{} |> Bunck.request(client)
  """

  def request(payload, client) do
    Bunck.Request.request(payload, client)
    |> assign_client(client)
    |> headers()
    |> sign()
    |> authenticate()
    |> format_request()
    |> do_request()
    |> process_response()
  end

  defp assign_client(request, client), do: %{request | client: client}

  defp headers(request) do
    %Bunck.Request{request | headers: (request.headers || []) ++ default_headers(request)}
  end

  defp default_headers(request) do
    [
      "User-Agent": "Bunck Elixir Client/0.1 (+https://hex.pm/packages/bunck)",
      "Cache-Control": "no-cache",
      "X-Bunq-Language": "en_US",
      "X-Bunq-Region": "en_US",
      "X-Bunq-Client-Request-Id": UUID.uuid4(),
      "X-Bunq-Geolocation": "0 0 0 0 000",
    ]
  end

  def sign(request) do
    %{request | headers: ["X-Bunq-Client-Signature": signature(request)] ++ request.headers}
  end

  defp signature(_ = %Bunck.Request{payload: %Bunck.Installation.Post{}}), do: ""
  defp signature(request) do
    headers_string =
      request.headers
      |> Enum.filter(fn header ->
        header_name = elem(header, 0)
        :"Cache-Control" == header_name || :"User-Agent" == header_name || header_name |> to_string() |> String.starts_with?("X-Bunq-")
      end)
      |> Enum.sort_by(fn header -> elem(header, 0) end)
      |> Enum.map(fn header -> "#{elem(header, 0)}: #{elem(header, 1)}" end)
      |> Enum.join("\n")

    "#{request.method |> String.upcase} #{request.path}\n#{headers_string}\n\n#{request.payload |> Poison.encode!}"
  end

  defp authenticate(request = %Bunck.Request{payload: %Bunck.Installation.Post{}}), do: request
  defp authenticate(request) do
    %{request | headers: ["X-Bunq-Client-Authentication": ""] ++ request.headers}
  end

  defp format_request(request) do
    %{request | method: request.method |> String.downcase,
      url: "https://sandbox.public.api.bunq.com#{request.path}",
      payload: request.payload |> Poison.encode!(),
      options: request.options || [],
    }
  end

  defp do_request(request) do
    request |> Map.take([:method, :url, :headers, :payload, :options]) |> IO.inspect
    :hackney.request(request.method, request.url, request.headers, request.payload, request.options)
  end

  defp process_response({:ok, status, headers, client}) do
    {:ok, body} = :hackney.body(client)
    {:ok, status, headers, body}
  end
end
