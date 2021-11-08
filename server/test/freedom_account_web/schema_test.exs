defmodule FreedomAccountWeb.SchemaTest do
  use FreedomAccountWeb.ConnCase, async: true

  @account_query """
  query account {
    my_account {
      funds {
        icon
        id
        name
      }
      id
      name
    }
  }
  """

  test "query: account", %{conn: conn} do
    account = build(:account)
    funds = build_list(3, :fund)

    FreedomAccountMock
    |> stub(:my_account, fn -> {:ok, account} end)
    |> stub(:list_funds, fn ^account -> funds end)

    expected_funds =
      Enum.map(funds, fn fund ->
        %{
          "icon" => fund.icon,
          "id" => fund.id,
          "name" => fund.name
        }
      end)

    response =
      conn
      |> post("/api", %{query: @account_query})
      |> json_response(200)

    assert %{
             "data" => %{
               "my_account" => %{
                 "funds" => expected_funds,
                 "id" => account.id,
                 "name" => account.name
               }
             }
           } == response
  end
end
