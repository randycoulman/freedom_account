defmodule FreedomAccountWeb.TransactionForm do
  @moduledoc """
  For making a transaction for a single fund.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Transactions
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    %{transaction: transaction} = assigns
    changeset = Transactions.change_transaction(transaction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> apply_action(assigns.action)}
  end

  defp apply_action(socket, :deposit) do
    %{funds: [fund]} = socket.assigns
    changeset = Transactions.new_deposit(fund)

    socket
    |> assign_form(changeset)
    |> assign(:heading, "Deposit")
    |> assign(:save, "Make Deposit")
  end

  defp apply_action(socket, :regular_withdrawal) do
    %{funds: funds} = socket.assigns
    changeset = Transactions.new_regular_withdrawal(funds)

    socket
    |> assign_form(changeset)
    |> assign(:heading, "Regular Withdrawal")
    |> assign(:save, "Make Withdrawal")
  end

  defp apply_action(socket, :withdrawal) do
    socket
    |> assign(:heading, "Withdraw")
    |> assign(:save, "Make Withdrawal")
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @heading %>
      </.header>

      <.simple_form
        for={@form}
        id="transaction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date]} label="Date" phx-debounce="blur" type="date" />
        <.input field={@form[:memo]} label="Memo" phx-debounce="blur" type="text" />
        <.inputs_for :let={li} field={@form[:line_items]}>
          <.input
            field={li[:amount]}
            label={Enum.at(@funds, li.index).name}
            phx-debounce="blur"
            type="text"
          />
          <.input field={li[:fund_id]} type="hidden" />
        </.inputs_for>
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-circle-mini" /> <%= @save %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"transaction" => transaction_params} = params
    %{transaction: transaction} = socket.assigns

    changeset =
      transaction
      |> Transactions.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", params, socket) do
    %{"transaction" => transaction_params} = params
    %{action: action} = socket.assigns

    save_transaction(socket, action, Params.atomize_keys(transaction_params))
  end

  defp save_transaction(socket, :deposit, params) do
    %{return_path: return_path} = socket.assigns

    case Transactions.deposit(params) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Deposit successful")
         |> push_patch(to: return_path)}

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_transaction(socket, action, params) when action in [:regular_withdrawal, :withdrawal] do
    %{return_path: return_path} = socket.assigns

    case Transactions.withdraw(params) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Withdrawal successful")
         |> push_patch(to: return_path)}

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
