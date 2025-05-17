defmodule FreedomAccountWeb.FundCard do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

  import FreedomAccountWeb.Card, only: [card: 1]
  import FreedomAccountWeb.CoreComponents

  alias FreedomAccount.Funds.Fund
  alias Phoenix.LiveView.JS

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :class, :string
  attr :fund, Fund, required: true
  attr :rest, :global

  def fund_card(assigns) do
    ~H"""
    <.card
      balance={@fund.current_balance}
      class={@class}
      data-testid="fund-card"
      icon={@fund.icon}
      name={@fund.name}
      {@rest}
    >
      <:action>
        <.link class="sr-only" navigate={~p"/funds/#{@fund}"}>Show</.link>
      </:action>
      <:action>
        <.link patch={~p"/funds/#{@fund}/edit"} title="Edit">
          <.icon name="hero-pencil-square-micro" /> Edit
        </.link>
      </:action>
      <:action>
        <.link
          data-confirm="Are you sure?"
          phx-click={JS.push("delete", value: %{id: @fund.id}) |> hide("#funds-#{@fund.id}")}
          title="Delete"
        >
          <.icon name="hero-trash-micro" /> Delete
        </.link>
      </:action>
      <:details>
        <div class="ml-12 mt-1 text-sm text-gray-500" data-testid="budget">
          {"#{@fund.budget} @ #{@fund.times_per_year} times/year"}
        </div>
      </:details>
    </.card>
    """
  end
end
