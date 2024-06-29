defmodule FreedomAccountWeb.FundList do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

  import FreedomAccountWeb.CoreComponents

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  def fund_list(assigns) do
    ~H"""
    <div class="p-2">
      <.header>Funds</.header>
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
end
