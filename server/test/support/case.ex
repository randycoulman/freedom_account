defmodule FreedomAccount.Case do
  @moduledoc """
  Shared setup for all tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import FreedomAccount.Factory
      import Hammox
      import unquote(__MODULE__)
    end
  end
end
