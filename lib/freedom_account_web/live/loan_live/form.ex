defmodule FreedomAccountWeb.LoanLive.Form do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Loans
  alias FreedomAccount.Loans.Loan
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :action, :string, required: true
  attr :loan, Loan, required: true
  attr :return_path, :string, required: true
  attr :title, :string, required: true

  @spec settings_form(Socket.assigns()) :: LiveView.Rendered.t()
  def settings_form(assigns) do
    ~H"""
    <.live_component id={@loan.id || :new} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    %{loan: loan} = assigns
    changeset = Loans.change_loan(loan)

    socket
    |> assign(assigns)
    |> assign_form(changeset)
    |> ok()
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="loan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:icon]} label="Icon" phx-debounce="blur" type="text" />
        <.input field={@form[:name]} label="Name" phx-debounce="blur" type="text" />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-circle-mini" /> Save Loan
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"loan" => loan_params} = params
    %{loan: loan} = socket.assigns

    changeset =
      loan
      |> Loans.change_loan(loan_params)
      |> Map.put(:action, :validate)

    socket
    |> assign_form(changeset)
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"loan" => loan_params} = params
    %{action: action} = socket.assigns

    save_loan(socket, action, Params.atomize_keys(loan_params))
  end

  defp save_loan(socket, :edit, loan_params) do
    %{loan: loan, return_path: return_path} = socket.assigns

    case Loans.update_loan(loan, loan_params) do
      {:ok, _loan} ->
        socket
        |> put_flash(:info, "Loan updated successfully")
        |> push_patch(to: return_path)
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign_form(changeset)
        |> noreply()
    end
  end

  defp save_loan(socket, :new, loan_params) do
    %{account: account, return_path: return_path} = socket.assigns

    case Loans.create_loan(account, loan_params) do
      {:ok, _loan} ->
        socket
        |> put_flash(:info, "Loan created successfully")
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
