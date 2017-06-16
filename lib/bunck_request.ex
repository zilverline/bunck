defprotocol Bunck.Request do
  defstruct [:client, :method, :path, :url, :headers, :payload, :options]

  def request(payload, client)
end

defimpl Bunck.Request, for: Bunck.Installation.Post do
  def request(payload, client) do
    %Bunck.Request{method: "POST", path: "/v1/installation", payload: %{payload | client_public_key: client.client_public_key}}
  end
end

# defimpl Bunck.Request, for: Bunck.DraftPayment.Post do
#   def request(client, payload) do
#     %Bunck.Request{method: "POST", path: "/v1/user/#{i.user_id}/monetary-account/#{i.account_id}/draft-payment", payload: payload}
#   end
# end

# defimpl Bunck.Request, for: Bunck.DraftPayment.Put do
#   def request(i) do
#     {"PUT", "/v1/user/#{i.user_id}/monetary-account/#{i.account_id}/draft-payment", i |> Map.from_struct |> Map.take([:status, :entries, :previous_updated_timestamp])}
#   end
# end
