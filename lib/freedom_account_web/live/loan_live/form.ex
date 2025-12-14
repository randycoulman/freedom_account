defmodule FreedomAccountWeb.LoanLive.Form do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias Ecto.Changeset
  alias FreedomAccount.Loans
  alias FreedomAccount.Loans.Loan
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveView

  @impl LiveView
  def mount(params, _session, socket) do
    socket
    |> assign(:return_to, return_to(params["return_to"]))
    |> apply_action(socket.assigns.live_action, params)
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <div>
      <.standard_form
        class="max-w-sm"
        for={@form}
        id="loan-form"
        phx-change="validate"
        phx-submit="save"
        title={@page_title}
      >
        <.input field={@form[:icon]} label="Icon" phx-debounce="blur" type="text" />
        <.input field={@form[:name]} label="Name" phx-debounce="blur" type="text" />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit" variant="primary">
            <.icon name="hero-check-circle-mini" /> Save Loan
          </.button>
        </:actions>
        <:actions>
          <.button navigate={return_path(@return_to, @loan)}>Cancel</.button>
        </:actions>
      </.standard_form>
    </div>
    """
  end

  @impl LiveView
  def handle_event("validate", params, socket) do
    %{"loan" => loan_params} = params
    changeset = Loans.change_loan(socket.assigns.loan, loan_params)

    socket
    |> assign(:form, to_form(changeset, action: :validate))
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"loan" => loan_params} = params
    save_loan(socket, socket.assigns.live_action, Params.atomize_keys(loan_params))
  end

  defp apply_action(socket, :edit, params) do
    id = String.to_integer(params["id"])

    case Enum.find(socket.assigns.loans, :not_found, &(&1.id == id)) do
      %Loan{} = loan ->
        changeset = Loans.change_loan(loan)

        socket
        |> assign(:form, to_form(changeset))
        |> assign(:loan, loan)
        |> assign(:page_title, "Edit Loan")

      :not_found ->
        socket
        |> put_flash(:error, "Loan is no longer present")
        |> push_navigate(to: ~p"/loans")
    end
  end

  defp apply_action(socket, :new, _params) do
    loan = %Loan{}
    changeset = Loans.change_loan(loan)

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:loan, loan)
    |> assign(:page_title, "Add Loan")
  end

  defp return_path(:index, _loan), do: ~p"/loans"
  defp return_path(:show, loan), do: ~p"/loans/#{loan}"

  defp return_to("show"), do: :show
  defp return_to(_other), do: :index

  defp save_loan(socket, :edit, loan_params) do
    case Loans.update_loan(socket.assigns.loan, loan_params) do
      {:ok, loan} ->
        socket
        |> put_flash(:info, "Loan updated successfully")
        |> push_navigate(to: return_path(socket.assigns.return_to, loan))
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end

  defp save_loan(socket, :new, loan_params) do
    case Loans.create_loan(socket.assigns.account, loan_params) do
      {:ok, loan} ->
        socket
        |> put_flash(:info, "Loan created successfully")
        |> push_navigate(to: return_path(socket.assigns.return_to, loan))
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end
end
