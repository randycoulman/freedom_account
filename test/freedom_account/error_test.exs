defmodule FreedomAccount.ErrorTest do
  use FreedomAccount.Case, async: true

  alias FreedomAccount.Error

  describe "not found errors" do
    test "generates human-readable error message with module name entity" do
      error = Error.not_found(entity: FreedomAccount.Accounts.Account)

      assert Exception.message(error) == "Could not find account"
    end

    test "generates human-readable error message with atom entity" do
      error = Error.not_found(entity: :atom)

      assert Exception.message(error) == "Could not find atom"
    end
  end
end
