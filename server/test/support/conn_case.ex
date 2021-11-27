defmodule FreedomAccountWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.
  """

  use ExUnit.CaseTemplate

  alias FreedomAccountWeb.Authentication

  using opts do
    quote do
      use FreedomAccount.Case, unquote(opts)

      # Import conveniences for testing with connections
      import Phoenix.ConnTest
      import Plug.Conn
      import unquote(__MODULE__)

      alias FreedomAccountWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint FreedomAccountWeb.Endpoint
    end
  end

  setup _context do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def sign_in(conn, user) do
    user_id = user.id

    FreedomAccountMock
    |> Hammox.stub(:find_user, fn ^user_id -> {:ok, user} end)

    Authentication.sign_in(conn, user)
  end
end
