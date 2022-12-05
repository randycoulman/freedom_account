defmodule FreedomAccountWeb.ParamsTest do
  use ExUnit.Case, async: true

  alias FreedomAccountWeb.Params

  describe "converting keys to atoms" do
    test "converts keys to known atoms" do
      params = %{"age" => 42, "name" => "NAME"}

      assert %{
               age: 42,
               name: "NAME"
             } = Params.atomize_keys(params)
    end

    test "raises an error for unknown atom" do
      params = %{"no_such_atom_exists" => true}

      assert_raise ArgumentError, fn -> Params.atomize_keys(params) end
    end
  end
end
