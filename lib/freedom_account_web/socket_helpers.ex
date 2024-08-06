defmodule FreedomAccountWeb.SocketHelpers do
  @moduledoc false
  alias Phoenix.LiveView.Socket

  @spec cont(Socket.t()) :: {:cont, Socket.t()}
  def cont(%Socket{} = socket), do: {:cont, socket}

  @spec halt(Socket.t()) :: {:halt, Socket.t()}
  def halt(%Socket{} = socket), do: {:halt, socket}

  @spec noreply(Socket.t()) :: {:noreply, Socket.t()}
  def noreply(%Socket{} = socket), do: {:noreply, socket}

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  def ok(%Socket{} = socket), do: {:ok, socket}
end
