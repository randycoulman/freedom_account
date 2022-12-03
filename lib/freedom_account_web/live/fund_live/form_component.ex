defmodule FreedomAccountWeb.FundLive.FormComponent do
  # use FreedomAccountWeb, :live_component

  # alias FreedomAccount.Funds

  # @impl true
  # def render(assigns) do
  #   ~H"""
  #   <div>
  #     <.header>
  #       <%= @title %>
  #       <:subtitle>Use this form to manage fund records in your database.</:subtitle>
  #     </.header>

  #     <.simple_form
  #       :let={f}
  #       for={@changeset}
  #       id="fund-form"
  #       phx-target={@myself}
  #       phx-change="validate"
  #       phx-submit="save"
  #     >
  #       <.input field={{f, :icon}} type="text" label="icon" />
  #       <.input field={{f, :name}} type="text" label="name" />
  #       <:actions>
  #         <.button phx-disable-with="Saving...">Save Fund</.button>
  #       </:actions>
  #     </.simple_form>
  #   </div>
  #   """
  # end

  # @impl true
  # def update(%{fund: fund} = assigns, socket) do
  #   changeset = Funds.change_fund(fund)

  #   {:ok,
  #    socket
  #    |> assign(assigns)
  #    |> assign(:changeset, changeset)}
  # end

  # @impl true
  # def handle_event("validate", %{"fund" => fund_params}, socket) do
  #   changeset =
  #     socket.assigns.fund
  #     |> Funds.change_fund(fund_params)
  #     |> Map.put(:action, :validate)

  #   {:noreply, assign(socket, :changeset, changeset)}
  # end

  # def handle_event("save", %{"fund" => fund_params}, socket) do
  #   save_fund(socket, socket.assigns.action, fund_params)
  # end

  # defp save_fund(socket, :edit, fund_params) do
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

  # defp save_fund(socket, :new, fund_params) do
  #   case Funds.create_fund(fund_params) do
  #     {:ok, _fund} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Fund created successfully")
  #        |> push_navigate(to: socket.assigns.navigate)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, changeset: changeset)}
  #   end
  # end
end
