defmodule FreedomAccount.Case do
  @moduledoc """
  Defines setup for any tests in this application.
  """
  use ExUnit.CaseTemplate

  alias FreedomAccount.Factory
  alias FreedomAccount.Transactions.DateCache

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  setup _context do
    Process.put(:account_topic, "account-#{System.unique_integer([:positive])}")
    Process.put(:funds_topic, "funds-#{System.unique_integer([:positive])}")
    Process.put(:loans_topic, "loans-#{System.unique_integer([:positive])}")
    Process.put(:transactions_topic, "transactions-#{System.unique_integer([:positive])}")
    :ok
  end

  @spec start_date_cache(map()) :: map()
  def start_date_cache(_context) do
    name = Factory.process_name(:date_cache)
    start_supervised!({DateCache, name: name})
    Process.put(:date_cache, name)

    %{date_cache: name}
  end
end
