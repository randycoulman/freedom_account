defmodule FreedomAccount.Case do
  @moduledoc """
  Defines setup for any tests in this application.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  setup _context do
    Process.put(:account_topic, "account-#{System.unique_integer([:positive])}")
    Process.put(:funds_topic, "funds-#{System.unique_integer([:positive])}")
    Process.put(:transactions_topic, "transactions-#{System.unique_integer([:positive])}")
    :ok
  end
end
