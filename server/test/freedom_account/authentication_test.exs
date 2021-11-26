defmodule FreedomAccount.AuthenticationTest do
  use FreedomAccount.DataCase

  alias FreedomAccount.Authentication

  describe "authentication" do
    test "finds user by name" do
      user = insert(:user)

      assert {:ok, ^user} = Authentication.authenticate(user.name)
    end

    test "returns unauthorized error if user not found" do
      assert {:error, :unauthorized} = Authentication.authenticate("no_such_user")
    end
  end

  describe "finding a user by ID" do
    test "returns the user if found" do
      user = insert(:user)

      assert {:ok, ^user} = Authentication.find_user(user.id)
    end

    test "returns not found error if not found" do
      id = generate_id()
      assert {:error, :not_found} = Authentication.find_user(id)
    end
  end
end
