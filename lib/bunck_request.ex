defprotocol Bunck.Request do
  defstruct [:client, :method, :path, :url, :headers, :payload, :options]

  def request(payload, client)
end

defimpl Bunck.Request, for: Bunck.Installation.Post do
  def request(payload, client), do: %Bunck.Request{method: "POST", path: "/v1/installation", payload: %{payload | client_public_key: client.client_public_key}}
end

defimpl Bunck.Request, for: Bunck.Installation.List do
  def request(payload, client), do: %Bunck.Request{method: "GET", path: "/v1/installation", payload: %{}}
end

defimpl Bunck.Request, for: Bunck.InstallationServerPublicKey.List do
  def request(payload, client), do: %Bunck.Request{method: "GET", path: "/v1/installation/#{payload.installation_id}/server-public-key", payload: %{}}
end

defimpl Bunck.Request, for: Bunck.DeviceServer.Post do
  def request(payload, client), do: %Bunck.Request{method: "POST", path: "/v1/device-server", payload: %{payload | secret: client.api_key}}
end

defimpl Bunck.Request, for: Bunck.SessionServer.Post do
  def request(payload, client), do: %Bunck.Request{method: "POST", path: "/v1/session-server", payload: payload}
end

defimpl Bunck.Request, for: Bunck.Payment.List do
  def request(payload, client), do: %Bunck.Request{method: "GET", path: "/v1/user/#{payload.user_id}/monetary-account/#{payload.monetary_account_id}/payment", payload: %{}}
end

defimpl Bunck.Request, for: Bunck.User.Get do
  def request(payload, client), do: %Bunck.Request{method: "GET", path: "/v1/user/#{payload.user_id}", payload: %{}}
end

defimpl Bunck.Request, for: Bunck.User.List do
  def request(payload, client), do: %Bunck.Request{method: "GET", path: "/v1/user", payload: %{}}
end

# defimpl Bunck.Request, for: Bunck.DraftPayment.Post do
#   def request(payload, client) do
#     %Bunck.Request{method: "POST", path: "/v1/user/#{i.user_id}/monetary-account/#{i.account_id}/draft-payment", payload: payload}
#   end
# end

