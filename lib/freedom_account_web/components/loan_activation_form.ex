defmodule FreedomAccountWeb.LoanActivationForm do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Loans
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :return_path, :string, required: true

  @spec loan_activation_form(Socket.assigns()) :: LiveView.Rendered.t()
  def loan_activation_form(assigns) do
    ~H"""
    <.live_component id={@account.id} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    %{account: account} = assigns
    changeset = Loans.change_activation(account)

    socket
    |> assign(assigns)
    |> assign_form(changeset)
    |> ok()
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>Activate/Deactivate Loans</.header>
      <.form
        for={@form}
        id="activation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.inputs_for :let={loan} field={@form[:loans]}>
          <.input field={loan[:active]} label={loan.data} type="checkbox" />
        </.inputs_for>
        <footer>
          <.button phx-disable-with="Updating..." type="submit" variant="primary">
            <.icon name="hero-check-circle-mini" /> Update Loans
          </.button>
        </footer>
      </.form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"activation" => activation_params} = params
    %{account: account} = socket.assigns

    changeset =
      account
      |> Loans.change_activation(activation_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"activation" => activation_params} = params
    %{account: account, return_path: return_path} = socket.assigns

    case Loans.update_activation(account, activation_params) do
      {:ok, _updated_loans} ->
        socket
        |> put_flash(:info, "Loans updated successfully")
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
