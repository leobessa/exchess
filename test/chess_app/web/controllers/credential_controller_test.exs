defmodule ChessApp.Web.CredentialControllerTest do
  use ChessApp.Web.ConnCase

  alias ChessApp.Account
  alias ChessApp.Account.Credential

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates credential and renders credential when data is valid", %{conn: conn} do
    conn = post conn, api_signup_path(conn, :create), account: %{"username" => "jon", "password" => "secret"}
    assert %{"id" => id} = json_response(conn, 201)["data"]

    credential = Account.get_credential!(id)
    assert credential.username == "jon"
    assert Credential.password_match?(credential, "secret")
  end

  test "does not create credential and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, api_signup_path(conn, :create), account: %{"username" => "jon", "password" => ""}
    assert json_response(conn, 422)["errors"] != %{}
    assert Account.list_credentials == []
  end

end
