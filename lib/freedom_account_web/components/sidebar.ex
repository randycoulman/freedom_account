defmodule FreedomAccountWeb.Sidebar do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

  import FreedomAccountWeb.CoreComponents

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :funds, :list, required: true
  attr :loans, :list, required: true

  def sidebar(assigns) do
    ~H"""
    <.fund_list funds={@funds} />
    <.loan_list loans={@loans} />
    """
  end

  attr :funds, :list, required: true

  defp fund_list(assigns) do
    ~H"""
    <div class="p-2">
      <.header>
        <.link navigate={~p"/funds"}>Funds</.link>
      </.header>
      <nav class="flex flex-col" id="fund-list">
        <div :for={fund <- @funds} class="flex flex-row justify-between" id={"fund-#{fund.id}"}>
          <.link navigate={~p"/funds/#{fund}"}>
            <%= fund %>
          </.link>
          <span class="text-right">
            <%= fund.current_balance %>
          </span>
        </div>
      </nav>
    </div>
    """
  end

  attr :loans, :list, required: true

  defp loan_list(assigns) do
    ~H"""
    <div class="p-2">
      <.header>
        <.link navigate={~p"/loans"}>Loans</.link>
      </.header>
      <nav class="flex flex-col" id="loan-list">
        <div :for={loan <- @loans} class="flex flex-row justify-between" id={"loan-#{loan.id}"}>
          <.link navigate={~p"/loans/#{loan}"}>
            <%= loan %>
          </.link>
          <span class="text-right">
            <%= loan.current_balance %>
          </span>
        </div>
      </nav>
    </div>
    """
  end
end
