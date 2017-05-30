defmodule ChessApp.Web.AuthTokenControllerTest do
  use ChessApp.Web.ConnCase

  alias ChessApp.Account

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates auth_token and renders jwt when data is valid", %{conn: conn} do
    Account.create_credential(%{"username" => "jon", "password" => "secret"})
    conn = post conn, api_auth_token_path(conn, :create), account: %{"username" => "jon", "password" => "secret"}
    assert %{"jwt" => jwt} = json_response(conn, 201)["data"]
    assert jwt
  end

  test "does not create auth_token and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, api_auth_token_path(conn, :create), account: %{"username" => "jon", "password" => ""}
    assert json_response(conn, 422) == %{"errors" => ["Invalid credential."]}
  end

end
