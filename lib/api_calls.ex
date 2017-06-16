defmodule Bunck.Installation do
  defmodule Post, do: defstruct [:client_public_key]
  defmodule Get, do: defstruct [:id]
  defmodule List, do: defstruct []
end

