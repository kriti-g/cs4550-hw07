defmodule UserStoriesWeb.PageControllerTest do
  use UserStoriesWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
  end
end
