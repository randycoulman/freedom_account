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
      <nav class="flex flex-col" id="fund-list" phx-update="stream">
        <.link :for={{id, fund} <- @funds} id={id} navigate={~p"/funds/#{fund}"}>
          <%= fund.icon %> <%= fund.name %>
        </.link>
      </nav>
    </div>
    """
  end
end
