defmodule FreedomAccountWeb.Sidebar do
  @moduledoc false
  use FreedomAccountWeb, :html
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
    <.sidebar_list
      balance={@balance}
      id="fund-list"
      item_path_fn={&~p"/funds/#{&1}"}
      items={@funds}
      title="Funds"
      title_path={~p"/funds"}
    />
    """
  end

  attr :balance, Money, required: true
  attr :loans, :list, required: true

  defp loan_list(assigns) do
    ~H"""
    <.sidebar_list
      balance={@balance}
      id="loan-list"
      item_path_fn={&~p"/loans/#{&1}"}
      items={@loans}
      title="Loans"
      title_path={~p"/loans"}
    />
    """
  end

  defp sidebar_list(assigns) do
    ~H"""
    <div class="p-2">
      <h2 class="flex flex-row font-semibold items-center justify-between text-sm">
        <.link navigate={@title_path}>{@title}</.link>
        <.money class="tabular-nums text-right" value={@balance} />
      </h2>
      <ul class="menu menu-sm px-0 w-full" id={@id}>
        <li :for={item <- @items} class="w-full">
          <.link
            class="flex flex-row gap-2 items-center justify-between px-0 w-full"
            id={"#{String.downcase(@title)}-#{item.id}"}
            navigate={@item_path_fn.(item)}
          >
            <span class="flex-1 min-w-0 !overflow-hidden truncate">
              {item}
            </span>
            <.money
              class="shrink-0 tabular-nums text-right"
              id={"#{String.downcase(@title)}-balance-#{item.id}"}
              value={item.current_balance}
            />
          </.link>
        </li>
      </ul>
    </div>
    """
  end
end
