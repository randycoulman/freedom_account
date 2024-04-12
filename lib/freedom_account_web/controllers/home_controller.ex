defmodule FreedomAccountWeb.HomeController do
  @moduledoc false
  use FreedomAccountWeb, :controller

  alias Plug.Conn

  @spec redirect_to_fund_list(Conn.t(), map()) :: Conn.t()
  def redirect_to_fund_list(conn, _params) do
    conn
    |> redirect(to: ~p"/funds")
    |> halt()
  end
end
