defmodule FreedomAccountWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by tests that require setting up
  a connection to test feature tests.

  Such tests rely on `PhoenixTest` and also import other functionality to
  make it easier to build common data structures and interact with pages.

  Finally, if the test case interacts with the database, we enable the SQL
  sandbox, so changes done to the database are reverted at the end of every
  test. If you are using PostgreSQL, you can even run database tests
  asynchronously by setting `use FreedomAccountWeb.FeatureCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias FreedomAccount.DataCase
  alias Phoenix.ConnTest

  using do
    quote do
      use FreedomAccountWeb, :verified_routes

      import FreedomAccountWeb.ElementSelectors
      import PhoenixTest
      import unquote(__MODULE__)
    end
  end

  setup tags do
    DataCase.setup_sandbox(tags)

    {:ok, conn: ConnTest.build_conn()}
  end
end
