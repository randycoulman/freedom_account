defmodule FreedomAccountWeb.TransactionForm do
  @moduledoc """
  For making a transaction for a single fund.
  """
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Transactions
  alias FreedomAccount.Transactions.Transaction
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  # For a new transaction, initial_funds is required, but for an existing
  # transaction it isn't.
  attr :account, Account, required: true
  attr :action, :string, required: true
  attr :all_funds, :list, required: true
  attr :initial_funds, :list, default: []
  attr :return_path, :string, required: true
  attr :transaction, Transaction, required: true

  @spec transaction_form(Socket.assigns()) :: LiveView.Rendered.t()
  def transaction_form(assigns) do
    ~H"""
    <.live_component id={@transaction.id || :new} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    %{action: action, initial_funds: initial_funds, transaction: transaction} = assigns

    changeset =
      if is_nil(transaction.id) do
        Transactions.new_transaction(initial_funds)
      else
        Transactions.change_transaction(transaction)
      end

    socket
    |> assign(assigns)
    |> apply_action(action)
    |> assign_form(changeset)
    |> ok()
  end

  defp apply_action(socket, :deposit) do
    socket
    |> assign(:heading, "Deposit")
    |> assign(:save, "Make Deposit")
  end

  defp apply_action(socket, :edit_transaction) do
    socket
    |> assign(:heading, "Edit Transaction")
    |> assign(:save, "Save Transaction")
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

    line_count =
      case form[:line_items].value do
        l when is_list(l) -> length(l)
        m when is_map(m) -> map_size(m)
      end

    assigns =
      assigns
      |> assign(:line_items_error, line_items_error)
      |> assign(:multi_line?, line_count > 1)

    ~H"""
    <div>
      <.header>
        {@heading}
      </.header>

      <.form
        for={@form}
        id="transaction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date]} label="Date" phx-debounce="blur" type="date" />
        <.input field={@form[:memo]} label="Memo" phx-debounce="blur" type="text" />
        <div :if={@line_items_error && @multi_line?} id="line-items-error">
          <.error>{@line_items_error}</.error>
        </div>
        <div class="grid grid-cols-2 gap-x-4 items-center mx-auto">
          <span />
          <label>Amount</label>
          <.inputs_for :let={li} field={@form[:line_items]}>
            <label>
              {find_fund(@all_funds, li[:fund_id].value)}
            </label>
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
          Total withdrawal: {@form[:total].value}
        </div>
        <footer>
          <.button phx-disable-with="Saving..." type="submit" variant="primary">
            <.icon name="hero-check-circle-mini" /> {@save}
          </.button>
        </footer>
      </.form>
    </div>
    """
  end

  defp find_fund(funds, fund_id) when is_binary(fund_id) do
    find_fund(funds, String.to_integer(fund_id))
  end

  defp find_fund(funds, fund_id) do
    Enum.find(funds, &(&1.id == fund_id))
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"transaction" => transaction_params} = params

    transaction = socket.assigns[:transaction] || %Transaction{}

    changeset =
      transaction
      |> Transactions.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"transaction" => transaction_params} = params
    %{action: action} = socket.assigns

    save_transaction(socket, action, Params.atomize_keys(transaction_params))
  end

  defp save_transaction(socket, :deposit, params) do
    %{account: account, return_path: return_path} = socket.assigns

    case Transactions.deposit(account, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Deposit successful")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp save_transaction(socket, :edit_transaction, params) do
    %{return_path: return_path, transaction: transaction} = socket.assigns

    case Transactions.update_transaction(transaction, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Transaction updated successfully")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp save_transaction(socket, action, params) when action in [:regular_withdrawal, :withdrawal] do
    %{account: account, return_path: return_path} = socket.assigns

    case Transactions.withdraw(account, params) do
      {:ok, _transaction} ->
        socket
        |> put_flash(:info, "Withdrawal successful")
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
