defmodule FreedomAccountWeb.FundLive.Form do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias FreedomAccount.Funds
  alias FreedomAccountWeb.Params
  alias Phoenix.LiveComponent

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

    changeset =
      socket.assigns.fund
      |> Funds.change_fund(fund_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", params, socket) do
    %{"fund" => fund_params} = params
    save_fund(socket, socket.assigns.action, Params.atomize_keys(fund_params))
  end

  defp save_fund(socket, :edit, fund_params) do
    case Funds.update_fund(socket.assigns.fund, fund_params) do
      {:ok, fund} ->
        notify_parent({:saved, fund})

        {:noreply,
         socket
         |> put_flash(:info, "Fund updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_fund(socket, :new, fund_params) do
    case Funds.create_fund(socket.assigns.account, fund_params) do
      {:ok, fund} ->
        notify_parent({:saved, fund})

        {:noreply,
         socket
         |> put_flash(:info, "Fund created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(message) do
    send(self(), {__MODULE__, message})
  end
end
