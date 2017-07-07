# Bunck

Bunck is a client for the Bunq API written in Elixir.

## Installation

The [package](https://hex.pm/packages/bunck) can be installed
by adding `bunck` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:bunck, "~> 0.1.4"}]
end
```

Also add `:bunck` to your list of applications.

## Usage Example

```elixir
Bunck.with_session(fn(client) ->
  %Bunck.User.List{} |> Bunck.Client.request(client) # get all users
  %Bunck.User.Get{user_id: 4} |> Bunck.Client.request(client) # get user with id 4

  {:ok, users} = %Bunck.User.List{} |> Bunck.Client.request(client)
  users |> Enum.map(fn(user) -> do_something_with(user) end) # iterate over *all* users, pagination included for free
end)
```

### You'll need
- An API key (get a developer's API key by chatting with Bunq support).

### Documentation (including examples) at [hexdocs](https://hexdocs.pm/bunck/api-reference.html).

### Contributing

Contributions (in the form of pull requests) are very welcome!

This library is incomplete. Not all endpoints are "implemented" yet (look in `/lib/api_calls.ex` and `/lib/bunck_request.ex` to see how to implement new requests. It's pretty simple, you'll get it.) There are also some convenience functions missing.
