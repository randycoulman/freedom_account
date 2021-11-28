defmodule FreedomAccountWeb.SchemaTest do
  use FreedomAccountWeb.ConnCase, async: true
  use Assertions.AbsintheCase, schema: FreedomAccountWeb.Schema

  alias FreedomAccountWeb.Authentication

  describe "mutation: login" do
    defp login_mutation do
      """
      mutation Login($username: String!) {
        login(username: $username) {
          #{document_for(:user)}
        }
      }
      """
    end

    test "logs the user in and remembers them in the session", %{conn: conn} do
      user = build(:user)
      username = user.name

      FreedomAccountMock
      |> expect(:authenticate, fn ^username -> {:ok, user} end)

      result_conn =
        conn
        |> post("/api", %{
          query: login_mutation(),
          variables: %{username: username}
        })

      response = json_response(result_conn, 200)

      assert %{
               "data" => %{
                 "login" => %{
                   "__typename" => "User",
                   "id" => user.id,
                   "name" => user.name
                 }
               }
             } == response

      assert Authentication.current_user(result_conn) == user
    end

    test "returns an error for an unknown user", %{conn: conn} do
      FreedomAccountMock
      |> stub(:authenticate, fn _username -> {:error, :unauthorized} end)

      result_conn =
        conn
        |> post("/api", %{
          query: login_mutation(),
          variables: %{username: "no_such_user"}
        })

      response = json_response(result_conn, 200)

      assert %{
               "errors" => [%{"message" => "unauthorized"}]
             } = response

      assert Authentication.current_user(result_conn) == nil
    end
  end

  describe "mutation: logout" do
    defp logout_mutation do
      """
      mutation Logout {
        logout
      }
      """
    end

    test "logs the user out and removes them from the session", %{conn: conn} do
      user = build(:user)

      result_conn =
        conn
        |> sign_in(user)
        |> post("/api", %{query: logout_mutation()})

      response = json_response(result_conn, 200)

      assert %{"data" => %{"logout" => true}} == response
      assert Authentication.current_user(result_conn) == nil
    end

    test "does nothing if no user is logged in", %{conn: conn} do
      result_conn =
        conn
        |> post("/api", %{query: logout_mutation()})

      response = json_response(result_conn, 200)

      assert %{"data" => %{"logout" => true}} == response
      assert Authentication.current_user(result_conn) == nil
    end
  end

  describe "query: myAccount" do
    defp my_account_query do
      """
      query MyAccount {
        myAccount {
          #{document_for(:account)}
        }
      }
      """
    end

    test "returns the logged-in user's account", %{conn: conn} do
      user = build(:user)
      account = build(:account, user: user)
      funds = build_list(3, :fund, account: account)

      FreedomAccountMock
      |> stub(:my_account, fn ^user -> {:ok, account} end)
      |> stub(:list_funds, fn ^account -> funds end)

      expected_funds =
        Enum.map(funds, fn fund ->
          %{
            "__typename" => "Fund",
            "icon" => fund.icon,
            "id" => fund.id,
            "name" => fund.name
          }
        end)

      response =
        conn
        |> sign_in(user)
        |> post("/api", %{query: my_account_query()})
        |> json_response(200)

      assert %{
               "data" => %{
                 "myAccount" => %{
                   "__typename" => "Account",
                   "depositsPerYear" => account.deposits_per_year,
                   "funds" => expected_funds,
                   "id" => account.id,
                   "name" => account.name
                 }
               }
             } == response
    end

    test "returns an error if there is no logged-in user", %{conn: conn} do
      response =
        conn
        |> post("/api", %{query: my_account_query()})
        |> json_response(200)

      assert %{
               "errors" => [%{"message" => "unauthorized"}]
             } = response
    end
  end

  describe "mutation: updateAccount" do
    defp update_account_mutation do
      """
        mutation UpdateAccount($input: AccountInput!) {
          updateAccount(input: $input) {
            #{document_for(:account, 1)}
          }
        }
      """
    end

    test "updates account properties", %{conn: conn} do
      account = build(:account)
      deposits_per_year = 26
      name = "NEW NAME"
      updated_account = %{account | deposits_per_year: deposits_per_year, name: name}
      params = %{deposits_per_year: deposits_per_year, id: account.id, name: name}

      FreedomAccountMock
      |> expect(:update_account, fn ^params -> {:ok, updated_account} end)

      response =
        conn
        |> post("/api", %{
          query: update_account_mutation(),
          variables: %{input: params}
        })
        |> json_response(200)

      assert %{
               "data" => %{
                 "updateAccount" => %{
                   "__typename" => "Account",
                   "depositsPerYear" => deposits_per_year,
                   "id" => account.id,
                   "name" => name
                 }
               }
             } == response
    end
  end

  describe "session persistence" do
    test "recovers session after logging in", %{conn: conn} do
      user = build(:user)
      account = build(:account, user: user)
      user_id = user.id
      username = user.name

      FreedomAccountMock
      |> stub(:authenticate, fn ^username -> {:ok, user} end)
      |> stub(:find_user, fn ^user_id -> {:ok, user} end)
      |> stub(:my_account, fn ^user -> {:ok, account} end)
      |> stub(:list_funds, fn ^account -> [] end)

      response =
        conn
        |> post("/api", %{query: login_mutation(), variables: %{username: username}})
        |> post("/api", %{query: my_account_query()})
        |> json_response(200)

      assert %{
               "data" => %{
                 "myAccount" => %{
                   "__typename" => "Account",
                   "depositsPerYear" => account.deposits_per_year,
                   "funds" => [],
                   "id" => account.id,
                   "name" => account.name
                 }
               }
             } == response
    end
  end
end
