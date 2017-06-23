defmodule Bunck.Client do
  defstruct [:api_key, :client_private_key, :client_public_key, :server_public_key, :installation_token, :session_token]
end
