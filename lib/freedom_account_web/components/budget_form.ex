defmodule FreedomAccountWeb.BudgetForm do
  @moduledoc """
  For bulk-updating the budget for all funds.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Funds
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    %{funds: funds} = assigns
    changeset = Funds.change_budget(funds)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
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
        <div class="grid grid-cols-3 gap-x-4 items-center mx-auto">
          <span />
          <.label>Budget</.label>
          <.label>Times/Year</.label>
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
          </.inputs_for>
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
    %{funds: funds} = socket.assigns

    changeset =
      funds
      |> Funds.change_budget(budget_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", params, socket) do
    %{"budget" => budget_params} = params
    %{funds: funds, return_path: return_path} = socket.assigns

    case Funds.update_budget(funds, budget_params) do
      {:ok, _updated_funds} ->
        {:noreply,
         socket
         |> put_flash(:info, "Budget updated successfully")
         |> push_patch(to: return_path)}

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
