defmodule ChessApp.Web.MatchControllerTest do
  use ChessApp.Web.ConnCase
  import ChessApp.Factory
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

  describe "index all matches" do
    test "on empty database", %{conn: conn} do
      build(:credential, %{username: "jon"}) |> with_password("secret") |> insert
      {:ok, auth_token} = ChessApp.Account.create_auth_token("jon", "secret")
      conn = conn
        |> put_req_header("authorization", "Bearer #{auth_token.jwt}")
        |> get(api_matches_path(conn, :index))

      assert [] = json_response(conn, 200)["data"]
    end

    test "returns single match", %{conn: conn} do
      build(:credential, %{username: "jon"}) |> with_password("secret") |> insert
      {:ok, auth_token} = ChessApp.Account.create_auth_token("jon", "secret")
      match = insert(:match)
      conn = conn
        |> put_req_header("authorization", "Bearer #{auth_token.jwt}")
        |> get(api_matches_path(conn, :index))
      assert json_response(conn, 200) == render_json("index.json", %{matches: [match]})
    end

    test "returns multiple matches with pagination", %{conn: conn} do
      build(:credential, %{username: "jon"}) |> with_password("secret") |> insert
      {:ok, auth_token} = ChessApp.Account.create_auth_token("jon", "secret")
      insert_list(20, :match)
      default_page_response = conn
        |> put_req_header("authorization", "Bearer #{auth_token.jwt}")
        |> get(api_matches_path(conn, :index))
        |> json_response(200)
      assert 10 == length(default_page_response["data"])
    end

    test "returns multiple matches with page parameter", %{conn: conn} do
      build(:credential, %{username: "jon"}) |> with_password("secret") |> insert
      {:ok, auth_token} = ChessApp.Account.create_auth_token("jon", "secret")
      insert_list(20, :match)
      page1_response = conn
        |> put_req_header("authorization", "Bearer #{auth_token.jwt}")
        |> get(api_matches_path(conn, :index), page: 1)
        |> json_response(200)
      page2_response = conn
        |> put_req_header("authorization", "Bearer #{auth_token.jwt}")
        |> get(api_matches_path(conn, :index), page: 2)
        |> json_response(200)
      assert 10 == length(page1_response["data"])
      assert 10 == length(page2_response["data"])
      page1_ids = for entry <- page1_response["data"], do: entry["id"], into: MapSet.new
      page2_ids = for entry <- page2_response["data"], do: entry["id"], into: MapSet.new
      assert MapSet.new == MapSet.intersection(page1_ids,page2_ids)
    end
  end

  defp render_json(template, assigns) do
    assigns = Map.new(assigns)

    ChessApp.Web.MatchView.render(template, assigns)
    |> Poison.encode!
    |> Poison.decode!
  end

end
