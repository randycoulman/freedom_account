defmodule FreedomAccountWeb.SchemaTest do
  use FreedomAccountWeb.ConnCase, async: true

  @funds_query """
  query listFunds {
    funds {
      icon
      id
      name
    }
  }
  """

  test "query: funds", %{conn: conn} do
    response =
      conn
      |> post("/api", %{query: @funds_query})
      |> json_response(200)

    assert %{
             "data" => %{
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
               ]
             }
           } == response
  end
end
