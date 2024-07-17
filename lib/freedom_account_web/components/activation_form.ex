defmodule FreedomAccountWeb.ActivationForm do
  @moduledoc false
  use FreedomAccountWeb, :live_component

  alias Ecto.Changeset
  alias FreedomAccount.Funds
  alias Phoenix.LiveComponent

  @impl LiveComponent
  def update(assigns, socket) do
    %{account: account} = assigns
    changeset = Funds.change_activation(account)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.header>Activate/Deactivate Funds</.header>
      <.simple_form
        for={@form}
        id="activation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.inputs_for :let={fund} field={@form[:funds]}>
          <.input field={fund[:active]} label={fund[:name].value} type="checkbox" />
        </.inputs_for>
        <:actions>
          <.button phx-disable-with="Updating..." type="submit">
            <.icon name="hero-check-circle-mini" /> Update Funds
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl LiveComponent
  def handle_event("validate", params, socket) do
    %{"activation" => activation_params} = params
    %{account: account} = socket.assigns

    changeset =
      account
      |> Funds.change_activation(activation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", params, socket) do
    %{"activation" => activation_params} = params
    %{account: account, return_path: return_path} = socket.assigns

    case Funds.update_activation(account, activation_params) do
      {:ok, _updated_funds} ->
        {:noreply,
         socket
         |> put_flash(:info, "Funds updated successfully")
         |> push_patch(to: return_path)}

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
