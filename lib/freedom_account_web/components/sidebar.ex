defmodule FreedomAccountWeb.Sidebar do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :funds, :list, required: true
  attr :funds_balance, Money, required: true
  attr :loans, :list, required: true
  attr :loans_balance, Money, required: true

  def sidebar(assigns) do
    ~H"""
    <div class="bg-base-300 text-base-content">
      <.fund_list balance={@funds_balance} funds={@funds} />
      <.loan_list balance={@loans_balance} loans={@loans} />
    </div>
    """
  end

  attr :balance, Money, required: true
  attr :funds, :list, required: true

  defp fund_list(assigns) do
    ~H"""
    <div class="p-2 text-xs/5">
      <h2 class="flex flex-row font-semibold items-center justify-between mb-2 text-sm">
        <.link navigate={~p"/funds"}>Funds</.link>
        <span class="tabular-nums text-right">{@balance}</span>
      </h2>
      <nav class="flex flex-col" id="fund-list">
        <div
          :for={fund <- @funds}
          class="flex flex-row gap-2 items-center justify-between"
          id={"fund-#{fund.id}"}
        >
          <.link class="truncate" navigate={~p"/funds/#{fund}"}>
            {fund}
          </.link>
          <span class="tabular-nums text-right">
            {fund.current_balance}
          </span>
        </div>
      </nav>
    </div>
    """
  end

  attr :balance, Money, required: true
  attr :loans, :list, required: true

  defp loan_list(assigns) do
    ~H"""
    <div class="p-2 text-xs/5">
      <h2 class="flex flex-row font-semibold items-center justify-between mb-2 text-sm">
        <.link navigate={~p"/loans"}>Loans</.link>
        <span class="tabular-nums text-right">{@balance}</span>
      </h2>
      <nav class="flex flex-col" id="loan-list">
        <div
          :for={loan <- @loans}
          class="flex flex-row gap-2 items-center justify-between"
          id={"loan-#{loan.id}"}
        >
          <.link class="link link-hover truncate" navigate={~p"/loans/#{loan}"}>
            {loan}
          </.link>
          <span class="tabular-nums text-right">
            {loan.current_balance}
          </span>
        </div>
      </nav>
    </div>
    """
  end
end
