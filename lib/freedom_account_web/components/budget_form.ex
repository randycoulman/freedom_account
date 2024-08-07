defmodule FreedomAccountWeb.BudgetForm do
  @moduledoc """
  For bulk-updating the budget for all funds.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias Phoenix.LiveComponent
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

  @impl LiveComponent
  def update(assigns, socket) do
    %{account: account, funds: funds} = assigns
    changeset = Funds.change_budget(account, funds)

    socket
    |> assign(assigns)
    |> assign_form(changeset)
    |> ok()
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>Update Budget</.header>
      <.simple_form
        for={@form}
        id="budget-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div>
          <div class="grid grid-cols-4 gap-x-4 items-center mx-auto">
            <span />
            <.label>Budget</.label>
            <.label>Times/Year</.label>
            <.label>Deposit Amount</.label>
            <.inputs_for :let={fund} field={@form[:funds]}>
              <.label><%= fund.data %></.label>
              <.input
                field={fund[:budget]}
                label={"Budget #{fund.index}"}
                label_class="sr-only"
                type="text"
              />
              <.input
                field={fund[:times_per_year]}
                label={"Times/Year #{fund.index}"}
                label_class="sr-only"
                type="text"
              />
              <span data-role={"deposit-amount-#{fund.index}"}>
                <%= fund[:regular_deposit_amount].value %>
              </span>
            </.inputs_for>
          </div>
          <div id="deposit-total">
            Total deposit amount: <%= @form[:total_deposit_amount].value %>
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Updating..." type="submit">
            <.icon name="hero-check-circle-mini" /> Update Budget
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"budget" => budget_params} = params
    %{account: account, funds: funds} = socket.assigns

    changeset =
      account
      |> Funds.change_budget(funds, budget_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"budget" => budget_params} = params
    %{account: account, funds: funds, return_path: return_path} = socket.assigns

    case Funds.update_budget(account, funds, budget_params) do
      {:ok, _updated_funds} ->
        socket
        |> put_flash(:info, "Budget updated successfully")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
