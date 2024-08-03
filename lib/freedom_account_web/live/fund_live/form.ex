defmodule FreedomAccountWeb.FundLive.Form do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Accounts.Account
  alias FreedomAccount.Funds
  alias FreedomAccount.Funds.Fund
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  attr :account, Account, required: true
  attr :action, :string, required: true
  attr :fund, Fund, required: true
  attr :return_path, :string, required: true
  attr :title, :string, required: true

  @spec settings_form(Socket.assigns()) :: LiveView.Rendered.t()
  def settings_form(assigns) do
    ~H"""
    <.live_component id={@fund.id || :new} module={__MODULE__} {assigns} />
    """
  end

  @impl LiveComponent
  def update(assigns, socket) do
    %{fund: fund} = assigns
    changeset = Funds.change_fund(fund)

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
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="fund-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:icon]} label="Icon" type="text" />
        <.input field={@form[:name]} label="Name" type="text" />
        <.input field={@form[:budget]} label="Budget" type="text" />
        <.input field={@form[:times_per_year]} label="Times/Year" type="text" />
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">
            <.icon name="hero-check-circle-mini" /> Save Fund
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"fund" => fund_params} = params
    %{fund: fund} = socket.assigns

    changeset =
      fund
      |> Funds.change_fund(fund_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", params, socket) do
    %{"fund" => fund_params} = params
    %{action: action} = socket.assigns

    save_fund(socket, action, Params.atomize_keys(fund_params))
  end

  defp save_fund(socket, :edit, fund_params) do
    %{fund: fund, return_path: return_path} = socket.assigns

    case Funds.update_fund(fund, fund_params) do
      {:ok, _fund} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fund updated successfully")
         |> push_patch(to: return_path)}

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_fund(socket, :new, fund_params) do
    %{account: account, return_path: return_path} = socket.assigns

    case Funds.create_fund(account, fund_params) do
      {:ok, _fund} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fund created successfully")
         |> push_patch(to: return_path)}

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
