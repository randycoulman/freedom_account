defmodule FreedomAccountWeb.Plugs.Context do
  @moduledoc """
  Plug for initializing Absinthe context.

  Populates the context with the currently logged-in user (if any).
  """

  @behaviour Plug

  alias FreedomAccountWeb.Authentication

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    case Authentication.current_user(conn) do
      nil -> %{}
      user -> %{current_user: user}
    end
  end
end
