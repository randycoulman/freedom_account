defmodule FreedomAccountWeb.Hooks.LoadInitialData.FundCache do
  @moduledoc false
  alias FreedomAccount.Funds.Fund

  @type t :: [Fund.t()]

  @spec add_fund(t(), Fund.t()) :: t()
  def add_fund(funds, %Fund{} = fund) do
    sort([fund | funds])
  end

  @spec delete_fund(t(), Fund.t()) :: t()
  def delete_fund(funds, %Fund{} = fund) do
    Enum.reject(funds, &(&1.id == fund.id))
  end

  @spec update_activations(t(), [Fund.t()]) :: t()
  def update_activations(funds, to_update) do
    to_update
    |> Enum.reduce(funds, &do_update_activation(&2, &1))
    |> sort()
  end

  @spec update_all(t(), [Fund.t()]) :: t()
  def update_all(funds, to_update) do
    to_update
    |> Enum.reduce(funds, &do_update_fund(&2, &1))
    |> sort()
  end

  @spec update_fund(t(), Fund.t()) :: t()
  def update_fund(funds, %Fund{} = fund) do
    funds
    |> do_update_fund(fund)
    |> sort()
  end

  defp do_update_activation(funds, %Fund{active: false} = fund) do
    delete_fund(funds, fund)
  end

  defp do_update_activation(funds, %Fund{active: true} = fund) do
    funds |> delete_fund(fund) |> add_fund(fund)
  end

  defp do_update_fund(funds, %Fund{} = fund) do
    Enum.map(funds, &replace_fund(&1, fund))
  end

  defp replace_fund(%Fund{id: id} = original, %Fund{id: id} = updated) do
    %{updated | current_balance: updated.current_balance || original.current_balance}
  end

  defp replace_fund(original, _updated), do: original

  defp sort(funds) do
    Enum.sort_by(funds, & &1.name)
  end
end
