defmodule FreedomAccountWeb.DepositForm do
  @moduledoc """
  For making a deposit to a fund.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Transactions
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    %{deposit: deposit} = assigns
    changeset = Transactions.change_transaction(deposit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Deposit
      </.header>

      <.simple_form
        for={@form}
        id="deposit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date]} label="Date" phx-debounce="blur" type="date" />
        <.input field={@form[:description]} label="Description" phx-debounce="blur" type="text" />
        <.inputs_for :let={li} field={@form[:line_items]}>
          <.input field={li[:amount]} label="Amount" phx-debounce="blur" type="text" />
          <.input field={li[:fund_id]} type="hidden" />
        </.inputs_for>
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-circle-mini" /> Make Deposit
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"transaction" => deposit_params} = params
    %{deposit: deposit} = socket.assigns

    changeset =
      deposit
      |> Transactions.change_transaction(deposit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", params, socket) do
    %{"transaction" => deposit_params} = params
    %{action: action} = socket.assigns

    save_transaction(socket, action, Params.atomize_keys(deposit_params))
  end

  defp save_transaction(socket, :new_deposit, params) do
    %{fund: fund, patch: patch} = socket.assigns

    case Transactions.deposit(params) do
      {:ok, _transaction} ->
        notify_parent({:balance_updated, fund})

        {:noreply,
         socket
         |> put_flash(:info, "Deposit created successfully")
         |> push_patch(to: patch)}

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(message) do
    send(self(), {__MODULE__, message})
  end
end
