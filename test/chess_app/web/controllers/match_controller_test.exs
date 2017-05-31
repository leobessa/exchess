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
    setup [:jwt_authorization]
    test "on empty database", %{conn: conn} do
      conn = conn
        |> get(api_matches_path(conn, :index))

      assert [] = json_response(conn, 200)["data"]
    end

    test "returns single match", %{conn: conn} do
      match = insert(:match)
      conn = conn
        |> get(api_matches_path(conn, :index))
      assert json_response(conn, 200) == render_json("index.json", %{matches: [match]})
    end

    test "returns multiple matches with pagination", %{conn: conn} do
      insert_list(20, :match)
      default_page_response = conn
        |> get(api_matches_path(conn, :index))
        |> json_response(200)
      assert 10 == length(default_page_response["data"])
    end

    test "returns multiple matches with page parameter", %{conn: conn} do
      insert_list(20, :match)
      page1_response = conn
        |> get(api_matches_path(conn, :index), page: 1)
        |> json_response(200)
      page2_response = conn
        |> get(api_matches_path(conn, :index), page: 2)
        |> json_response(200)
      assert 10 == length(page1_response["data"])
      assert 10 == length(page2_response["data"])
      page1_ids = for entry <- page1_response["data"], do: entry["id"], into: MapSet.new
      page2_ids = for entry <- page2_response["data"], do: entry["id"], into: MapSet.new
      assert MapSet.new == MapSet.intersection(page1_ids,page2_ids)
    end
  end

  describe "index playing matches" do
    setup [:jwt_authorization]

    test "returns single playing_match", %{conn: conn} do
      match = insert(:playing_match)
      response = conn
        |> get(api_playing_matches_path(conn, :playing_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: [match]})
    end

    test "does not list waiting_for_opponent matches", %{conn: conn} do
      insert(:waiting_for_opponent_match)
      response = conn
        |> get(api_playing_matches_path(conn, :playing_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: []})
    end

    test "does not list finished matches", %{conn: conn} do
      insert(:finished_match)
      response = conn
        |> get(api_playing_matches_path(conn, :playing_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: []})
    end

    test "returns multiple entries with pagination", %{conn: conn} do
      insert_list(20, :playing_match)
      default_page_response = conn
        |> get(api_playing_matches_path(conn, :playing_matches_index))
        |> json_response(200)
      assert 10 == length(default_page_response["data"])
    end

    test "returns multiple entries with page parameter", %{conn: conn} do
      insert_list(20, :playing_match)
      page1_response = conn
        |> get(api_playing_matches_path(conn, :playing_matches_index), page: 1)
        |> json_response(200)
      page2_response = conn
        |> get(api_playing_matches_path(conn, :playing_matches_index), page: 2)
        |> json_response(200)
      assert 10 == length(page1_response["data"])
      assert 10 == length(page2_response["data"])
      page1_ids = for entry <- page1_response["data"], do: entry["id"], into: MapSet.new
      page2_ids = for entry <- page2_response["data"], do: entry["id"], into: MapSet.new
      assert MapSet.new == MapSet.intersection(page1_ids,page2_ids)
    end
  end

  describe "index waiting_for_opponent matches" do
    setup [:jwt_authorization]

    test "returns single waiting_for_opponent", %{conn: conn} do
      match = insert(:waiting_for_opponent_match)
      response = conn
        |> get(api_waiting_for_opponent_matches_path(conn, :waiting_for_opponent_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: [match]})
    end

    test "does not list playing matches", %{conn: conn} do
      insert(:playing_match)
      response = conn
        |> get(api_waiting_for_opponent_matches_path(conn, :waiting_for_opponent_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: []})
    end

    test "does not list finished matches", %{conn: conn} do
      insert(:finished_match)
      response = conn
        |> get(api_waiting_for_opponent_matches_path(conn, :waiting_for_opponent_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: []})
    end

    test "returns multiple entries with pagination", %{conn: conn} do
      insert_list(20, :waiting_for_opponent_match)
      default_page_response = conn
        |> get(api_waiting_for_opponent_matches_path(conn, :waiting_for_opponent_matches_index))
        |> json_response(200)
      assert 10 == length(default_page_response["data"])
    end

    test "returns multiple entries with page parameter", %{conn: conn} do
      insert_list(20, :waiting_for_opponent_match)
      page1_response = conn
        |> get(api_waiting_for_opponent_matches_path(conn, :waiting_for_opponent_matches_index), page: 1)
        |> json_response(200)
      page2_response = conn
        |> get(api_waiting_for_opponent_matches_path(conn, :waiting_for_opponent_matches_index), page: 2)
        |> json_response(200)
      assert 10 == length(page1_response["data"])
      assert 10 == length(page2_response["data"])
      page1_ids = for entry <- page1_response["data"], do: entry["id"], into: MapSet.new
      page2_ids = for entry <- page2_response["data"], do: entry["id"], into: MapSet.new
      assert MapSet.new == MapSet.intersection(page1_ids,page2_ids)
    end
  end

  describe "index finished matches" do
    setup [:jwt_authorization]

    test "returns single finished match", %{conn: conn} do
      match = insert(:finished_match)
      response = conn
        |> get(api_finished_matches_path(conn, :finished_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: [match]})
    end

    test "does not list playing matches", %{conn: conn} do
      insert(:playing_match)
      response = conn
        |> get(api_finished_matches_path(conn, :finished_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: []})
    end

    test "does not list waiting_for_opponent matches", %{conn: conn} do
      insert(:waiting_for_opponent_match)
      response = conn
        |> get(api_finished_matches_path(conn, :finished_matches_index))
        |> json_response(200)
      assert response == render_json("index.json", %{matches: []})
    end

    test "returns multiple entries with pagination", %{conn: conn} do
      insert_list(20, :finished_match)
      default_page_response = conn
        |> get(api_finished_matches_path(conn, :finished_matches_index))
        |> json_response(200)
      assert 10 == length(default_page_response["data"])
    end

    test "returns multiple entries with page parameter", %{conn: conn} do
      insert_list(20, :finished_match)
      page1_response = conn
        |> get(api_finished_matches_path(conn, :finished_matches_index), page: 1)
        |> json_response(200)
      page2_response = conn
        |> get(api_finished_matches_path(conn, :finished_matches_index), page: 2)
        |> json_response(200)
      assert 10 == length(page1_response["data"])
      assert 10 == length(page2_response["data"])
      page1_ids = for entry <- page1_response["data"], do: entry["id"], into: MapSet.new
      page2_ids = for entry <- page2_response["data"], do: entry["id"], into: MapSet.new
      assert MapSet.new == MapSet.intersection(page1_ids,page2_ids)
    end
  end

  def jwt_authorization(context) do
    %{username: username} = build(:credential) |> with_password("secret") |> insert
    {:ok, auth_token} = ChessApp.Account.create_auth_token(username, "secret")
    conn = context.conn
      |> put_req_header("authorization", "Bearer #{auth_token.jwt}")
    [conn: conn]
  end

  defp render_json(template, assigns) do
    assigns = Map.new(assigns)

    ChessApp.Web.MatchView.render(template, assigns)
    |> Poison.encode!
    |> Poison.decode!
  end

end
