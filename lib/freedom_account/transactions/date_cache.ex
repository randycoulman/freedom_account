defmodule FreedomAccount.Transactions.DateCache do
  @moduledoc false
  use Agent

  alias FreedomAccount.Accounts.Account

  @type opt :: {:name, Agent.name()}

  @spec start_link([opt]) :: Agent.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)

    Agent.start_link(fn -> %{} end, name: name)
  end

  @spec last_date(GenServer.name(), Account.id()) :: Date.t()
  @spec last_date(GenServer.name(), Account.id(), Date.t()) :: Date.t()
  def last_date(cache, account_id, %Date{} = default \\ Timex.today(:local)) do
    Agent.get(cache, &Map.get(&1, account_id, default))
  end

  @spec remember(GenServer.name(), Account.id(), Date.t()) :: :ok
  def remember(cache, account_id, %Date{} = date) do
    Agent.update(cache, &Map.put(&1, account_id, date))
  end
end
