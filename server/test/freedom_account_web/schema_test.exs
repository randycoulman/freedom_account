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
    response =
      conn
      |> post("/api", %{query: @account_query})
      |> json_response(200)

    assert %{
             "data" => %{
               "my_account" => %{
                 "funds" => [
                   %{
                     "icon" => "🏚️",
                     "id" => "1",
                     "name" => "Home Repairs"
                   },
                   %{
                     "icon" => "🚘",
                     "id" => "2",
                     "name" => "Car Repairs"
                   },
                   %{
                     "icon" => "💸",
                     "id" => "3",
                     "name" => "Property Taxes"
                   }
                 ],
                 "id" => "100",
                 "name" => "Initial Account"
               }
             }
           } == response
  end
end
