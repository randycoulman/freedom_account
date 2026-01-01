defmodule FreedomAccountWeb.AccountTabs do
  @moduledoc false
  use FreedomAccountWeb, :html
  use Phoenix.Component

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :active, :atom, required: true, values: [:funds, :loans, :transactions]
  attr :funds_balance, Money, required: true
  attr :loans_balance, Money, required: true

  def account_tabs(assigns) do
    ~H"""
    <div class="tabs tabs-lift" role="tablist">
      <.link class={["tab", @active == :funds && "tab-active"]} navigate={~p"/funds"} role="tab">
        <.tab_label balance={@funds_balance} title="Funds" />
      </.link>
      <.link class={["tab", @active == :loans && "tab-active"]} navigate={~p"/loans"} role="tab">
        <.tab_label balance={@loans_balance} title="Loans" />
      </.link>
      <.link
        class={["tab", @active == :transactions && "tab-active"]}
        navigate={~p"/transactions"}
        role="tab"
      >
        <.tab_label title="Transactions" />
      </.link>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :balance, Money, default: nil

  defp tab_label(assigns) do
    ~H"""
    <div class="flex flex-row gap-4 justify-between">
      <h3>{@title}</h3>
      <.money :if={@balance} value={@balance} />
    </div>
    """
  end
end
