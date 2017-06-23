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
    |> authenticate()
    |> sign()
    |> format_request()
    |> do_request()
    |> process_response()
    |> validate_response(client)
    |> process_response_json()
  end

  defp assign_client(request, client), do: %{request | client: client}

  defp headers(request) do
    %Bunck.Request{request | headers: (request.headers || []) ++ default_headers()}
  end

  defp default_headers do
    [
      "User-Agent": "Bunck Elixir Client/0.1 (+https://hex.pm/packages/bunck)",
      "Cache-Control": "no-cache",
      "X-Bunq-Language": "en_US",
      "X-Bunq-Region": "en_US",
      "X-Bunq-Client-Request-Id": UUID.uuid4(),
      "X-Bunq-Geolocation": "0 0 0 0 000",
    ]
  end

  defp authenticate(request = %Bunck.Request{payload: %Bunck.Installation.Post{}}), do: request
  defp authenticate(request = %Bunck.Request{payload: %Bunck.SessionServer.Post{}}) do
    %{request | headers: ["X-Bunq-Client-Authentication": request.client.installation_token] ++ request.headers}
  end
  defp authenticate(request = %Bunck.Request{payload: %Bunck.DeviceServer.Post{}}) do
    %{request | headers: ["X-Bunq-Client-Authentication": request.client.installation_token] ++ request.headers}
  end
  defp authenticate(request) do
    %{request | headers: ["X-Bunq-Client-Authentication": request.client.session_token] ++ request.headers}
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
      |> header_signature_string()

    "#{request.method |> String.upcase} #{request.path}\n#{headers_string}\n\n#{request.payload |> Poison.encode!}"
    |> :public_key.sign(:sha256, client_private_key(request.client))
    |> :base64.encode()
  end

  defp header_signature_string(headers) do
    headers
    |> Enum.sort_by(fn header -> elem(header, 0) end)
    |> Enum.map(fn header -> "#{elem(header, 0)}: #{elem(header, 1)}" end)
    |> Enum.join("\n")
  end

  defp client_private_key(client) do
    client.client_private_key
    |> :public_key.pem_decode()
    |> List.first()
    |> :public_key.pem_entry_decode()
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
  defp process_response(response), do: response # on error, simply return to the user

  defp validate_response({:ok, status, headers, body}, client) do
    headers_string =
      headers
      |> Enum.filter(fn header ->
        name = elem(header, 0) |> to_string()
        name != "X-Bunq-Server-Signature" && name |> String.starts_with?("X-Bunq-")
      end)
      |> header_signature_string()

    signature =
      headers
      |> Enum.find(fn(header) -> elem(header, 0) == "X-Bunq-Server-Signature" end)
      |> elem(1)
      |> :base64.decode()

    verified = "#{status}\n#{headers_string}\n\n#{body}"
    |> :public_key.verify(:sha256, signature, server_public_key(client))

    if verified do
      {:ok, status, headers, body}
    else
      {:error, "Could not verify response signature"}
    end
  end

  defp server_public_key(client) do
    client.server_public_key
    |> :public_key.pem_decode()
    |> List.first()
    |> :public_key.pem_entry_decode()
  end

  defp process_response_json({:ok, status, headers, body}) do
    {:ok, decoded_body} = Poison.decode(body)
    {:ok, status, headers, decoded_body}
  end
end
