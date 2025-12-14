defmodule FreedomAccountWeb.LoanCard do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

  import FreedomAccountWeb.Card, only: [card: 1]
  import FreedomAccountWeb.CoreComponents

  alias FreedomAccount.Loans.Loan
  alias Phoenix.LiveView.JS

  # credo:disable-for-this-file Credo.Check.Readability.Specs
  # Reason: All component functions take a map of assigns that is fully
  # specified and checked at compile time by `attr` and `slot`, and they all
  # return a HEEx template, so no spec is necessary here.

  attr :class, :string
  attr :loan, Loan, required: true
  attr :rest, :global

  def loan_card(assigns) do
    ~H"""
    <.card
      balance={@loan.current_balance}
      class={@class}
      data-testid="loan-card"
      icon={@loan.icon}
      name={@loan.name}
      {@rest}
    >
      <:action>
        <.link class="sr-only" navigate={~p"/loans/#{@loan}"}>Show</.link>
      </:action>
      <:action>
        <.link navigate={~p"/loans/#{@loan}/edit"} title="Edit">
          <.icon name="hero-pencil-square-micro" /> Edit
        </.link>
      </:action>
      <:action>
        <.link
          data-confirm="Are you sure?"
          phx-click={JS.push("delete", value: %{id: @loan.id}) |> hide("#loans-#{@loan.id}")}
          title="Delete"
        >
          <.icon name="hero-trash-micro" /> Delete
        </.link>
      </:action>
    </.card>
    """
  end
end
