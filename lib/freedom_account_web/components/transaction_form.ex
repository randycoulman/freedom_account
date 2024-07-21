defmodule FreedomAccountWeb.TransactionForm do
  @moduledoc """
  For making a transaction for a single fund.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.Transaction
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    %{action: action, funds: funds} = assigns
    changeset = Transactions.new_transaction(funds)

    {:ok,
     socket
     |> assign(assigns)
     |> apply_action(action)
     |> assign_form(changeset)}
  end

  defp apply_action(socket, :deposit) do
    socket
    |> assign(:heading, "Deposit")
    |> assign(:save, "Make Deposit")
  end

  defp apply_action(socket, :regular_withdrawal) do
    socket
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
    %{form: form} = assigns

    line_items_error =
      case form.errors[:line_items] do
        nil -> nil
        error -> translate_error(error)
      end

    assigns =
      assigns
      |> assign(:line_items_error, line_items_error)
      |> assign(:multi_line?, length(form[:line_items].value) > 1)

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
        <div :if={@line_items_error && @multi_line?} id="line-items-error">
          <.error><%= @line_items_error %></.error>
        </div>
        <div class="grid grid-cols-3 gap-x-4 items-center mx-auto">
          <span />
          <.label>Amount</.label>
          <span />
          <.inputs_for :let={li} field={@form[:line_items]}>
            <.label><%= Enum.at(@funds, li.index).name %></.label>
            <.input
              field={li[:amount]}
              label={"Amount #{li.index}"}
              label_class="sr-only"
              phx-debounce="blur"
              type="text"
            />
            <.input field={li[:fund_id]} type="hidden" />
          </.inputs_for>
        </div>
        <div :if={@multi_line?} id="transaction-total">
          Total withdrawal: <%= @form[:total].value %>
        </div>
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

    changeset =
      %Transaction{}
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
    %{account: account, return_path: return_path} = socket.assigns

    case Transactions.withdraw(account, params) do
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
