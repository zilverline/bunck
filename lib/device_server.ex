defmodule Bunck.DeviceServerWrapper do
  def start_link do
    Agent.start_link(fn() ->
      %Bunck.Client{api_key: Application.get_env(Bunck, :api_key)} |> add_installation_to_client()
    end, name: __MODULE__)
  end

  def get_session_client do
    Agent.get(__MODULE__, fn(client) -> client end)
    |> add_session_to_client()
  end

  defp add_installation_to_client(client, description \\ "Elixir Server") do
    private_key = generate_private_key()
    public_key = public_key_pem_from_private_key(private_key)
    new_client = %{client | client_public_key: public_key, client_private_key: private_key}
    {:ok, installation_resp} = %Bunck.Installation.Post{} |> Bunck.request(new_client)
    server_public_key =
      installation_resp.body
      |> Map.get("Response")
      |> Enum.find(fn
                     %{"ServerPublicKey" => _} -> true
                     _ -> false
      end)
      |> Map.get("ServerPublicKey") |> Map.get("server_public_key")

    installation_token =
      installation_resp.body
      |> Map.get("Response")
      |> Enum.find(fn
                     %{"Token" => _} -> true
                     _ -> false
      end)
      |> Map.get("Token") |> Map.get("token")
    new_new_client = %{new_client | installation_token: installation_token, server_public_key: server_public_key}
    %Bunck.DeviceServer.Post{description: description} |> Bunck.request(new_new_client)
    new_new_client
  end

  defp add_session_to_client(client) do
    {:ok, session_resp} = %Bunck.SessionServer.Post{secret: client.api_key} |> Bunck.request(client)
    session_token =
      session_resp.body
      |> Map.get("Response")
      |> Enum.find(fn
                     %{"Token" => _} -> true
                     _ -> false
      end)
      |> Map.get("Token") |> Map.get("token")
    %{client | session_token: session_token}
  end

  defp generate_private_key do
    :public_key.generate_key({:rsa, 2048, 65537})
  end

  defp public_key_pem_from_private_key(private_key) do
    pubkey = {:RSAPublicKey, elem(private_key, 2), elem(private_key, 3)}
    pem_entry = :public_key.pem_entry_encode(:SubjectPublicKeyInfo, pubkey)
    :public_key.pem_encode([pem_entry])
  end
end
