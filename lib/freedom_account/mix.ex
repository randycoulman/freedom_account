defmodule FreedomAccount.Mix do
  @moduledoc false
  use Boundary, deps: [FreedomAccount.Accounts, FreedomAccount.Error, FreedomAccount.Funds, FreedomAccount.Transactions]
end
