defmodule FreedomAccountWeb.FundLive.FetchFund do
  @moduledoc """
  Fetches the fund identified by the params and adds it to the assigns.

  If the fund can't be found, return to the fund list page.
  """
  use FreedomAccountWeb, :hook

  alias FreedomAccount.Funds.Fund
  alias Phoenix.LiveView.Socket

  @spec on_mount(atom(), map(), map(), Socket.t()) :: {:cont | :halt, Socket.t()}
  def on_mount(:default, params, _session, socket) do
    id = String.to_integer(params["id"])

    case Enum.find(socket.assigns.funds, :not_found, &(&1.id == id)) do
      %Fund{} = fund ->
        socket
        |> assign(:fund, fund)
        |> cont()

      :not_found ->
        socket
        |> put_flash(:error, "Fund not found")
        |> push_navigate(~p"/funds")
        |> halt()
    end
  end
end
