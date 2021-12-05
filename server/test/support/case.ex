defmodule FreedomAccount.Case do
  @moduledoc """
  Shared setup for all tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Assertions
      import FreedomAccount.Factory
      import Hammox
      import ShorterMaps
      import unquote(__MODULE__)
    end
  end
end
