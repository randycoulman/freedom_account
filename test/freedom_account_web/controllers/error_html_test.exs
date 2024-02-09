defmodule FreedomAccountWeb.ErrorHTMLTest do
  @moduledoc false

  use FreedomAccountWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  alias FreedomAccountWeb.ErrorHTML

  test "renders 404.html" do
    assert render_to_string(ErrorHTML, "404", "html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(ErrorHTML, "500", "html", []) ==
             "Internal Server Error"
  end
end
