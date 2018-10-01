defmodule LedgerWeb.HealthControllerTest do
  use LedgerWeb.ConnCase

  describe "health response" do
    test "sends 200 status code and no body when requested", %{conn: conn} do
      conn = get conn, health_path(conn, :health)
      assert response(conn, 200)
    end
  end
end