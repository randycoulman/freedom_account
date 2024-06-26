defmodule FreedomAccountWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use FreedomAccountWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Phoenix.ConnTest

  using opts do
    quote do
      use FreedomAccount.DataCase, unquote(opts)
      use FreedomAccountWeb, :verified_routes

      import FreedomAccountWeb.ElementSelectors
      import Phoenix.ConnTest
      import PhoenixTest
      import Plug.Conn
      import unquote(__MODULE__)

      @endpoint FreedomAccountWeb.Endpoint
    end
  end

  setup _context do
    {:ok, conn: ConnTest.build_conn()}
  end
end
