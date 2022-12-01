defmodule FreedomAccountWeb.PageController do
  use FreedomAccountWeb, :controller

  alias Plug.Conn

  @spec home(Conn.t(), map) :: Conn.t()
  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
