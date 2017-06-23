defmodule Bunck.Installation do
  defmodule Post, do: defstruct [:client_public_key]
  defmodule Get, do: defstruct [:id]
  defmodule List, do: defstruct []
end

defmodule Bunck.InstallationServerPublicKey do
  defmodule List, do: defstruct [:installation_id]
end

defmodule Bunck.DeviceServer do
  defmodule Post, do: defstruct [:description, :secret]
end

defmodule Bunck.SessionServer do
  defmodule Post, do: defstruct [:secret]
end

defmodule Bunck.Payment do
  defmodule List, do: defstruct [:user_id, :monetary_account_id]
end

defmodule Bunck.User do
  defmodule Get, do: defstruct [:user_id]
  defmodule List, do: defstruct []
end

defmodule Bunck.MonetaryAccount do
  defmodule List, do: defstruct [:user_id]
end

defmodule Bunck.GetPath, do: defstruct [:path]
