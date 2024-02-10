defmodule FreedomAccountWeb.FundLive.Form do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias FreedomAccount.Funds
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to add a new fund.</:subtitle>
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
        <:actions>
          <.button phx-disable-with="Saving..." type="submit">Save Fund</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def update(%{fund: fund} = assigns, socket) do
    changeset = Funds.change_fund(fund)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl LiveComponent
  def handle_event("validate", %{"fund" => fund_params}, socket) do
    changeset =
      socket.assigns.fund
      |> Funds.change_fund(fund_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"fund" => fund_params}, socket) do
    save_fund(socket, socket.assigns.action, Params.atomize_keys(fund_params))
  end

  # defp save_fund(socket, :edit_fund, fund_params) do
  #   case Funds.update_fund(socket.assigns.fund, fund_params) do
  #     {:ok, _fund} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Fund updated successfully")
  #        |> push_navigate(to: socket.assigns.navigate)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

  defp save_fund(socket, :new_fund, fund_params) do
    %{account: account, navigate: navigate} = socket.assigns

    case Funds.create_fund(account, fund_params) do
      {:ok, _fund} ->
        {:noreply,
         socket
         |> put_flash(:info, "Fund created successfully")
         |> push_navigate(to: navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
