defmodule FreedomAccountWeb.AccountTabs do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

  import FreedomAccountWeb.CoreComponents

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :active, :atom, required: true, values: [:funds, :loans]

  def account_tabs(assigns) do
    ~H"""
    <.tab_bar>
      <:tab active={@active == :funds}>
        <.link navigate={~p"/funds"}>Funds</.link>
      </:tab>
      <:tab active={@active == :loans}>
        <.link navigate={~p"/loans"}>Loans</.link>
      </:tab>
    </.tab_bar>
    """
  end
end
