defmodule FreedomAccountWeb.FundLive.BudgetForm do
  @moduledoc """
  For bulk-updating the budget for all funds.
  """
  use FreedomAccountWeb, :live_view

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :funds, :list, required: true
  attr :return_path, :string, required: true

  @spec budget_form(Socket.assigns()) :: LiveView.Rendered.t()
  def budget_form(assigns) do
    ~H"""
    <.live_component id={@account.id} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveView
  def mount(_params, _session, socket) do
    changeset = Funds.change_budget(socket.assigns.account, socket.assigns.funds)

    socket
    |> assign(:page_title, "Update Budget")
    |> assign(:form, to_form(changeset))
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col items-center max-w-3xl mx-auto">
        <.header>Update Budget</.header>
        <.form
          class="w-full"
          for={@form}
          id="budget-form"
          phx-change="validate"
          phx-submit="save"
        >
          <div>
            <div class="grid grid-cols-4 gap-x-4 items-center mx-auto">
              <span />
              <label>Budget</label>
              <label>Times/Year</label>
              <label>Deposit Amount</label>
              <.inputs_for :let={fund} field={@form[:funds]}>
                <label>{fund.data}</label>
                <.input
                  field={fund[:budget]}
                  label={"Budget #{fund.index}"}
                  label_class="sr-only"
                  phx-debounce="blur"
                  type="text"
                />
                <.input
                  field={fund[:times_per_year]}
                  label={"Times/Year #{fund.index}"}
                  label_class="sr-only"
                  phx-debounce="blur"
                  type="text"
                />
                <span data-role={"deposit-amount-#{fund.index}"}>
                  {fund[:regular_deposit_amount].value}
                </span>
              </.inputs_for>
              <div class="col-span-4 font-semibold mt-4 text-center" id="deposit-total">
                Total deposit amount: {@form[:total_deposit_amount].value}
              </div>
            </div>
          </div>
          <footer class="flex gap-4 justify-center mt-6">
            <.button phx-disable-with="Updating..." type="submit" variant="primary">
              <.icon name="hero-check-circle-mini" /> Update Budget
            </.button>
            <.button navigate={~p"/funds"}>Cancel</.button>
          </footer>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_event("validate", params, socket) do
    %{"budget" => budget_params} = params
    changeset = Funds.change_budget(socket.assigns.account, socket.assigns.funds, budget_params)

    socket
    |> assign(:form, to_form(changeset, action: :validate))
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"budget" => budget_params} = params

    case Funds.update_budget(socket.assigns.account, socket.assigns.funds, budget_params) do
      {:ok, _updated_funds} ->
        socket
        |> put_flash(:info, "Budget updated successfully")
        |> push_navigate(to: ~p"/funds")
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end
end
