defmodule FreedomAccountWeb.Account.Form do
  @moduledoc """
  For for editing account settings.
  """

  use FreedomAccountWeb, :live_component

  alias FreedomAccount.Accounts
  alias FreedomAccount.Funds
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    %{account: account} = assigns
    changeset = Accounts.change_account(account)
    funds = Funds.list_funds(account)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:funds, funds)
     |> assign_form(changeset)}
  end

  @impl LiveComponent
  def render(assigns) do
    options =
      for fund <- assigns.funds do
        {"#{fund.icon} #{fund.name}", fund.id}
      end

    assigns = assign(assigns, :options, [{"", nil} | options])

    ~H"""
    <div>
      <.header>
        Edit Account Settings
      </.header>

      <.simple_form
        for={@form}
        id="account-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:deposits_per_year]} label="Deposits / year" type="number" />
        <.input field={@form[:name]} label="Name" type="text" />
        <.input
          field={@form[:default_fund_id]}
          id="default-fund"
          label="Default fund"
          options={@options}
          type="select"
        />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-circle-mini" /> Save Account
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", %{"account" => account_params}, socket) do
    %{account: account} = socket.assigns

    changeset =
      account
      |> Accounts.change_account(account_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    save_account(socket, Params.atomize_keys(account_params))
  end

  defp save_account(socket, account_params) do
    %{account: account, navigate: navigate} = socket.assigns

    case Accounts.update_account(account, account_params) do
      {:ok, _account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account updated successfully")
         |> push_navigate(to: navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
