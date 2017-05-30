defmodule ChessApp.Web.MatchControllerTest do
  use ChessApp.Web.ConnCase

  alias ChessApp.Chess

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates macth and renders it when data is valid", %{conn: conn} do
    ChessApp.Account.create_credential(%{username: "jon", password: "secret"})
    {:ok, auth_token} = ChessApp.Account.create_auth_token("jon", "secret")
    conn = conn
      |> put_req_header("authorization", "Bearer #{auth_token.jwt}")
      |> post(api_chess_match_path(conn, :create))
    assert %{"id" => id} = json_response(conn, 201)["data"]
    match = Chess.get_match!(id)
    assert match.player1_id == auth_token.account_id
  end

  test "does not create macthes when auth is not provided", %{conn: conn} do
    conn = post conn, api_chess_match_path(conn, :create)
    assert json_response(conn, 403)["errors"] == ["Authentication required"]
    assert Chess.list_matches() == []
  end

end
