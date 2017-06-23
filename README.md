# Bunck

Bunck is a client for the Bunq API written in Elixir.

## Installation

The [package](https://hex.pm/packages/bunck) can be installed
by adding `bunck` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:bunck, "~> 0.1.0"}]
end
```

Also add `:bunck` to your list of applications.

## Usage

### You'll need
- An API key (get a developer's API key by chatting with Bunq support).
- A private / public key pair. This can be generated with the following commands:
```sh
openssl genrsa -out bunq_private.pem 2048
openssl rsa -in bunq_private.pem -pubout -out bunq_public.pem
```

Never commit these keys to source control!

### Documentation (including examples) at [hexdocs](https://hexdocs.pm/bunck/api-reference.html).

### Contributing

Contributions (in the form of pull requests) are very welcome!

This library is incomplete. Not all endpoints are "implemented" yet (look in `/lib/api_calls.ex` and `/lib/bunck_request.ex` to see how to implement new requests. It's pretty simple, you'll get it.) There are also some convenience functions missing.
