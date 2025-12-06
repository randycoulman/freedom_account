defmodule FreedomAccountWeb.LoanLive.Index do
  @moduledoc false
  use FreedomAccountWeb, :live_view

  import FreedomAccountWeb.AccountBar, only: [account_bar: 1]
  import FreedomAccountWeb.AccountTabs, only: [account_tabs: 1]
  import FreedomAccountWeb.LoanActivationForm, only: [loan_activation_form: 1]
  import FreedomAccountWeb.LoanCard, only: [loan_card: 1]
  import FreedomAccountWeb.LoanLive.Form, only: [settings_form: 1]

  alias FreedomAccount.Error
  alias FreedomAccount.Error.NotFoundError
  alias FreedomAccount.Loans
  alias FreedomAccount.Loans.Loan
  alias FreedomAccountWeb.Layouts
  alias Phoenix.LiveView

  @impl LiveView
  def handle_params(params, _url, socket) do
    %{live_action: action} = socket.assigns

    socket
    |> assign(:loan, nil)
    |> assign(:return_path, ~p"/loans")
    |> apply_action(action, params)
    |> noreply()
  end

  defp apply_action(socket, :activate, _params) do
    assign(socket, :page_title, "Activate/Deactivate")
  end

  defp apply_action(socket, :edit, params) do
    id = String.to_integer(params["id"])

    case fetch_loan(socket, id) do
      {:ok, %Loan{} = loan} ->
        socket
        |> assign(:page_title, "Edit Loan")
        |> assign(:loan, loan)

      {:error, %NotFoundError{}} ->
        put_flash(socket, :error, "Loan is no longer present")
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Add Loan")
    |> assign(:loan, %Loan{})
  end

  defp apply_action(socket, _action, _params) do
    socket
    |> assign(:page_title, "Loans")
    |> assign(:loan, nil)
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.account_bar account={@account} balance={@account_balance} return_to="loans" />
      <.account_tabs active={:loans} funds_balance={@funds_balance} loans_balance={@loans_balance} />
      <div class="flex flex-row gap-2 justify-end py-4">
        <.link patch={~p"/loans/activate"} phx-click={JS.push_focus()}>
          <.button>
            <.icon name="hero-archive-box-mini" /> Activate/Deactivate
          </.button>
        </.link>
        <.link patch={~p"/loans/new"}>
          <.button>
            <.icon name="hero-plus-circle-mini" /> Add Loan
          </.button>
        </.link>
      </div>

      <div class="flex flex-col">
        <div :if={@loans == []} class="mx-auto p-4" id="no-loans">
          This account has no active loans. Use the Add Loan button to add one.
        </div>
        <.loan_card
          :for={loan <- @loans}
          class="hover:cursor-pointer"
          id={"loans-#{loan.id}"}
          loan={loan}
          phx-click={JS.navigate(~p"/loans/#{loan}")}
        />
      </div>

      <.modal
        :if={@live_action == :activate}
        id="activate-modal"
        show
        on_cancel={JS.patch(@return_path)}
      >
        <.loan_activation_form account={@account} return_path={@return_path} />
      </.modal>

      <.modal
        :if={@live_action in [:edit, :new]}
        id="loan-modal"
        show
        on_cancel={JS.patch(~p"/loans")}
      >
        <.settings_form
          account={@account}
          action={@live_action}
          loan={@loan}
          return_path={~p"/loans"}
          title={@page_title}
        />
      </.modal>
    </Layouts.app>
    """
  end

  @impl LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, loan} <- fetch_loan(socket, id),
         :ok <- Loans.delete_loan(loan) do
      noreply(socket)
    else
      {:error, error} ->
        socket
        |> put_flash(:error, Exception.message(error))
        |> noreply()
    end
  end

  defp fetch_loan(socket, id) do
    %{loans: loans} = socket.assigns

    with %Loan{} = loan <- Enum.find(loans, {:error, Error.not_found(details: %{id: id}, entity: Fund)}, &(&1.id == id)) do
      {:ok, loan}
    end
  end
end
