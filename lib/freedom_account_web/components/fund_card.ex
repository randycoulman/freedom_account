defmodule FreedomAccountWeb.FundCard do
  @moduledoc false
  use FreedomAccountWeb, :verified_routes
  use Phoenix.Component

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
    <div
      class={[
        " bg-white flex group items-center justify-between max-w-lg mx-auto p-4 rounded-xl shadow w-full",
        @class
      ]}
      data-testid="fund-card"
      {@rest}
    >
      <div>
        <div class="flex items-center">
          <div class="w-10 flex justify-center text-2xl" data-testid="icon">
            {@fund.icon}
          </div>
          <div class="flex items-center ml-2 gap-2">
            <div class="text-lg font-semibold text-gray-900" data-testid="name">
              {@fund.name}
            </div>
            <.actions fund={@fund} />
          </div>
        </div>
        <div class="ml-12 mt-1 text-sm text-gray-500" data-testid="budget">
          {"#{@fund.budget} @ #{@fund.times_per_year} times/year"}
        </div>
      </div>
      <div class="flex flex-col items-end">
        <div class="text-2xl font-semibold text-gray-900 tabular-nums" data-testid="balance">
          {@fund.current_balance}
        </div>
      </div>
    </div>
    """
  end

  defp actions(assigns) do
    ~H"""
    <div class="hidden group-hover:flex gap-1 text-md">
      <div class="sr-only">
        <.link navigate={~p"/funds/#{@fund}"}>Show</.link>
      </div>
      <.link class="text-gray-400 hover:text-gray-600" patch={~p"/funds/#{@fund}/edit"} title="Edit">
        <.icon name="hero-pencil-square-micro" /> Edit
      </.link>
      <.link
        class="text-gray-400 hover:text-gray-600"
        data-confirm="Are you sure?"
        phx-click={JS.push("delete", value: %{id: @fund.id}) |> hide("#funds2-#{@fund.id}")}
        title="Delete"
      >
        <.icon name="hero-trash-micro" /> Delete
      </.link>
    </div>
    """
  end
end
