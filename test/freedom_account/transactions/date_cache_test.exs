defmodule FreedomAccount.Transactions.DateCacheTest do
  use FreedomAccount.Case, async: true

  alias FreedomAccount.Factory
  alias FreedomAccount.LocalTime
  alias FreedomAccount.Transactions.DateCache

  setup do
    name = Factory.process_name(:date_cache)
    start_supervised!({DateCache, name: name})

    %{cache: name}
  end

  test "caches provided date", %{cache: cache} do
    account_id = Factory.id()
    date = Factory.date()

    assert :ok = DateCache.remember(cache, account_id, date)
    assert DateCache.last_date(cache, account_id, Factory.date()) == date
  end

  test "caches different dates for different accounts", %{cache: cache} do
    account_id = Factory.id()
    other_account_id = Factory.id()
    other_date = Factory.date()
    default = Factory.date()

    :ok = DateCache.remember(cache, other_account_id, other_date)
    assert DateCache.last_date(cache, account_id, default) == default
  end

  test "returns provided default if no date cached", %{cache: cache} do
    default = Factory.date()

    assert DateCache.last_date(cache, Factory.id(), default) == default
  end

  test "returns today's date if no date cached and no default provided", %{cache: cache} do
    assert DateCache.last_date(cache, Factory.id()) == LocalTime.today()
  end
end
