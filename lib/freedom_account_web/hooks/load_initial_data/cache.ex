defmodule FreedomAccountWeb.Hooks.LoadInitialData.Cache do
  @moduledoc false
  alias FreedomAccount.Funds.Fund
  alias FreedomAccount.Loans.Loan

  @type element :: Fund.t() | Loan.t()
  @type t :: [element()]

  @spec add(t(), element()) :: t()
  def add(cache, element) do
    sort([element | cache])
  end

  @spec delete(t(), element()) :: t()
  def delete(cache, element) do
    Enum.reject(cache, &(&1.id == element.id))
  end

  @spec update_activations(t(), [element()]) :: t()
  def update_activations(cache, to_update) do
    to_update
    |> Enum.reduce(cache, &do_update_activation(&2, &1))
    |> sort()
  end

  @spec update_all(t(), [element()]) :: t()
  def update_all(cache, to_update) do
    to_update
    |> Enum.reduce(cache, &do_update(&2, &1))
    |> sort()
  end

  @spec update(t(), element()) :: t()
  def update(cache, element) do
    cache
    |> do_update(element)
    |> sort()
  end

  defp do_update_activation(cache, %{active: false} = element) do
    delete(cache, element)
  end

  defp do_update_activation(cache, %{active: true} = element) do
    cache |> delete(element) |> add(element)
  end

  defp do_update(cache, %{} = element) do
    Enum.map(cache, &replace(&1, element))
  end

  defp replace(%{id: id} = original, %{id: id} = updated) do
    %{updated | current_balance: updated.current_balance || original.current_balance}
  end

  defp replace(original, _updated), do: original

  defp sort(cache) do
    Enum.sort_by(cache, & &1.name)
  end
end
