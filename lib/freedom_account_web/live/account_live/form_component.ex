defmodule FreedomAccountWeb.AccountLive.FormComponent do
  # use FreedomAccountWeb, :live_component

  # alias FreedomAccount.Accounts

  # @impl true
  # def render(assigns) do
  #   ~H"""
  #   <div>
  #     <.header>
  #       <%= @title %>
  #       <:subtitle>Use this form to manage account records in your database.</:subtitle>
  #     </.header>

  #     <.simple_form
  #       :let={f}
  #       for={@changeset}
  #       id="account-form"
  #       phx-target={@myself}
  #       phx-change="validate"
  #       phx-submit="save"
  #     >
  #       <.input field={{f, :deposits_per_year}} type="number" label="deposits_per_year" />
  #       <.input field={{f, :name}} type="text" label="name" />
  #       <:actions>
  #         <.button phx-disable-with="Saving...">Save Account</.button>
  #       </:actions>
  #     </.simple_form>
  #   </div>
  #   """
  # end

  # @impl true
  # def update(%{account: account} = assigns, socket) do
  #   changeset = Accounts.change_account(account)

  #   {:ok,
  #    socket
  #    |> assign(assigns)
  #    |> assign(:changeset, changeset)}
  # end

  # @impl true
  # def handle_event("validate", %{"account" => account_params}, socket) do
  #   changeset =
  #     socket.assigns.account
  #     |> Accounts.change_account(account_params)
  #     |> Map.put(:action, :validate)

  #   {:noreply, assign(socket, :changeset, changeset)}
  # end

  # def handle_event("save", %{"account" => account_params}, socket) do
  #   save_account(socket, socket.assigns.action, account_params)
  # end

  # defp save_account(socket, :edit, account_params) do
  #   case Accounts.update_account(socket.assigns.account, account_params) do
  #     {:ok, _account} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Account updated successfully")
  #        |> push_navigate(to: socket.assigns.navigate)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

  # defp save_account(socket, :new, account_params) do
  #   case Accounts.create_account(account_params) do
  #     {:ok, _account} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Account created successfully")
  #        |> push_navigate(to: socket.assigns.navigate)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, changeset: changeset)}
  #   end
  # end
end
