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

  alias FreedomAccount.DataCase
  alias Phoenix.ConnTest
  alias Phoenix.HTML

  using do
    quote do
      # The default endpoint for testing
      use FreedomAccountWeb, :verified_routes

      # Import conveniences for testing with connections
      import Phoenix.ConnTest
      import Plug.Conn
      import unquote(__MODULE__)

      @endpoint FreedomAccountWeb.Endpoint
    end
  end

  setup tags do
    DataCase.setup_sandbox(tags)
    {:ok, conn: ConnTest.build_conn()}
  end

  @spec escaped(String.t()) :: String.t()
  def escaped(string) do
    string |> HTML.html_escape() |> HTML.safe_to_string()
  end
end
