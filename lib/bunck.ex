defmodule Bunck do
  use Application

  @moduledoc """
  Bunck is a client for the Bunq API.

  Configure an API key in `config.exs`:
  ```elixir
  config Bunck. api_key: System.get_env("BUNQ_API_KEY")
  ```

  Then you can make calls using the Bunq API. Bunck takes care of public / private keys, installation, device servers, and sessions.

  Example:

  ```elixir
  Bunck.Client.with_session(fn(client) ->
    %Bunck.User.List{} |> Bunck.Client.request(client) # get all users
    %Bunck.User.Get{user_id: 4} |> Bunck.Client.request(client) # get user with id 4
  end)
  ```

  You can also iterate over a response using `Enum`:
  ```elixir
  Bunck.Client.with_session(fn(client) ->
    with {:ok, res} <- %Bunck.User.List{} |> Bunck.Client.request(client),
    do: Enum.map(fn(user) -> do_something_with(user) end)
  end)
  ```
  """

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Bunck.DeviceServerWrapper, [])
    ]

    Supervisor.start_link(children, [strategy: :one_for_one, name: Bunck.Supervisor])
  end
end
