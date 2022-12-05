defmodule FreedomAccountWeb.Params do
  @moduledoc """
  Utility functions for working with form params.
  """

  @typep attributes :: %{optional(atom) => any}
  @typep params :: %{optional(String.t()) => any}

  @spec atomize_keys(params) :: attributes
  def atomize_keys(params) do
    params
    |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Map.new()
  end
end
