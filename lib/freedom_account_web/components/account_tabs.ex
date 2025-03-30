defmodule FreedomAccountWeb.AccountTabs do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

  import FreedomAccountWeb.CoreComponents

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :active, :atom, required: true, values: [:funds, :loans, :transactions]
  attr :funds_balance, Money, required: true
  attr :loans_balance, Money, required: true

  def account_tabs(assigns) do
    ~H"""
    <.tab_bar>
      <:tab active={@active == :funds}>
        <.link navigate={~p"/funds"}>
          <.tab_label balance={@funds_balance} title="Funds" />
        </.link>
      </:tab>
      <:tab active={@active == :loans}>
        <.link navigate={~p"/loans"}>
          <.tab_label balance={@loans_balance} title="Loans" />
        </.link>
      </:tab>
      <:tab active={@active == :transactions}>
        <.link navigate={~p"/transactions"}>
          <.tab_label title="Transactions" />
        </.link>
      </:tab>
    </.tab_bar>
    """
  end

  attr :title, :string, required: true
  attr :balance, Money, default: nil

  defp tab_label(assigns) do
    ~H"""
    <div class="flex flex-row gap-4 justify-between">
      <h3>{@title}</h3>
      <span :if={@balance}>{@balance}</span>
    </div>
    """
  end
end
