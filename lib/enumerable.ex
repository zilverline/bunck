defimpl Enumerable, for: Bunck.Response do
  defmodule ResponseList, do: defstruct [:list, :next_path, :client]

  alias Bunck.Response

  def count(_), do: {:error, __MODULE__}
  def member?(_,_), do: {:error, __MODULE__}

  def reduce(_, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(response = %Response{}, acc, fun) do
    reduce(%ResponseList{list: response.body["Response"], next_path: response.body["Pagination"]["older_url"], client: response.client}, acc, fun)
  end
  def reduce(response_list, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(response_list, &1, fun)}
  def reduce(response_list = %{list: [], next_path: nil}, {:cont, acc}, fun), do: {:done, acc}
  def reduce(response_list = %{list: []}, {:cont, acc}, fun) do
    {:ok, new_response} = %Bunck.GetPath{path: response_list.next_path} |> Bunck.request(response_list.client)
    reduce(new_response, {:cont, acc}, fun)
  end
  def reduce(response_list = %{list: [h|t]}, {:cont, acc}, fun) do
    reduce(%{response_list | list: t}, fun.(h, acc), fun)
  end
end

