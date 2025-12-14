defmodule FreedomAccountWeb.LoanLive.ActivationForm do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  alias Ecto.Changeset
  alias FreedomAccount.Loans
  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    changeset = Loans.change_activation(socket.assigns.account)

    socket
    |> assign(:page_title, "Activate/Deactivate Loans")
    |> assign(:form, to_form(changeset))
    |> ok()
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <div>
      <.header>Activate/Deactivate Loans</.header>
      <.standard_form
        class="max-w-lg"
        for={@form}
        id="activation-form"
        phx-change="validate"
        phx-submit="save"
        title={@page_title}
      >
        <div class="grid justify-center">
          <.inputs_for :let={loan} field={@form[:loans]}>
            <.input field={loan[:active]} label={loan.data} type="checkbox" />
          </.inputs_for>
        </div>
        <:actions>
          <.button phx-disable-with="Updating..." type="submit" variant="primary">
            <.icon name="hero-check-circle-mini" /> Update Loans
          </.button>
          <.button navigate={~p"/loans"}>Cancel</.button>
        </:actions>
      </.standard_form>
    </div>
    """
  end

  @impl LiveView
  def handle_event("validate", params, socket) do
    %{"activation" => activation_params} = params
    changeset = Loans.change_activation(socket.assigns.account, activation_params)

    socket
    |> assign(:form, to_form(changeset, action: :validate))
    |> noreply()
  end

  def handle_event("save", params, socket) do
    %{"activation" => activation_params} = params

    case Loans.update_activation(socket.assigns.account, activation_params) do
      {:ok, _updated_loans} ->
        socket
        |> put_flash(:info, "Loans updated successfully")
        |> push_navigate(to: ~p"/loans")
        |> noreply()

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(:form, to_form(changeset))
        |> noreply()
    end
  end
end
