defmodule ChessApp.Web.MatchChannelTest do
  use ChessApp.Web.ChannelCase

  alias ChessApp.Web.MatchChannel
  alias ChessApp.Web.UserSocket
  import ChessApp.Factory

  @starting_game_state "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  test "initial state of the match is sent after player1 join" do
    %{username: username} = build(:credential) |> with_password("secret") |> insert
    {:ok, auth_token} = ChessApp.Account.create_auth_token(username, "secret")
    {:ok, socket} = connect(UserSocket, %{"jwt" => auth_token.jwt})
    player1_id = auth_token.account_id
    match = insert(:match, %{player1_id: player1_id})
    socket
      |> subscribe_and_join(MatchChannel, "match:#{match.id}")
    assert_push "game_state_sync", %{
      fen: @starting_game_state,
      player1_id: ^player1_id, player2_id: nil
    }
    actual_match = ChessApp.Chess.get_match!(match.id)
    assert actual_match.player1_id == player1_id
    assert actual_match.player2_id == nil
  end

  test "initial state of the match is sent after player2 join" do
    %{id: jon_id} = build(:credential) |> with_password("secret") |> insert
    %{id: sam_id,username: sam_username} = build(:credential) |> with_password("secret") |> insert
    {:ok, auth_token} = ChessApp.Account.create_auth_token(sam_username, "secret")
    {:ok, socket} = connect(UserSocket, %{"jwt" => auth_token.jwt})
    match = insert(:match, %{player1_id: jon_id})
    socket
      |> subscribe_and_join(MatchChannel, "match:#{match.id}")
    assert_push "game_state_sync", %{
      fen: @starting_game_state,
      player1_id: ^jon_id, player2_id: ^sam_id
    }

    actual_match = ChessApp.Chess.get_match!(match.id)
    assert actual_match.player1_id == jon_id
    assert actual_match.player2_id == sam_id
  end

  test "initial state of the match is sent after for viewers after join" do
    %{username: vic_username} = build(:credential) |> with_password("secret") |> insert
    {:ok, auth_token} = ChessApp.Account.create_auth_token(vic_username, "secret")
    {:ok, socket} = connect(UserSocket, %{"jwt" => auth_token.jwt})
    %{id: match_id, player1_id: player1_id, player2_id: player2_id} = insert(:playing_match)
    socket
      |> subscribe_and_join(MatchChannel, "match:#{match_id}")
    assert_push "game_state_sync", %{
      fen: @starting_game_state,
      player1_id: ^player1_id, player2_id: ^player2_id
    }
  end

  test "player1 request move on initial state" do
    %{username: username} = build(:credential) |> with_password("secret") |> insert
    {:ok, auth_token} = ChessApp.Account.create_auth_token(username, "secret")
    {:ok, socket} = connect(UserSocket, %{"jwt" => auth_token.jwt})
    player1_id = auth_token.account_id
    match = insert(:match, %{player1_id: player1_id})
    {:ok,_reply, socket} = socket
      |> subscribe_and_join(MatchChannel, "match:#{match.id}")
    assert_push "game_state_sync", %{fen: @starting_game_state, player1_id: ^player1_id, player2_id: nil}
    ref = push socket, "move", %{"an" => "e2e4"}
    assert_reply ref, :ok, %{"an" => "e2e4"}
    expected_match = ChessApp.Chess.get_match!(match.id)
    assert_broadcast "game_state_updated", ^expected_match
  end

  test "player2 request move on player1's turn" do
    %{id: player1_id} = insert(:credential)
    %{username: player2_username, id: player2_id} = build(:credential) |> with_password("secret") |> insert
    {:ok, auth_token} = ChessApp.Account.create_auth_token(player2_username, "secret")
    {:ok, socket} = connect(UserSocket, %{"jwt" => auth_token.jwt})
    match = insert(:match, %{player1_id: player1_id})
    {:ok,_reply, socket} = socket
      |> subscribe_and_join(MatchChannel, "match:#{match.id}")
    assert_push "game_state_sync", %{fen: @starting_game_state, player1_id: ^player1_id, player2_id: ^player2_id}
    ref = push socket, "move", %{"an" => "e2e4"}
    assert_reply ref, :error, %{"errors" => ["not_black_turn"]}
  end

  test "player1 request move on player2's turn" do
    match = insert(:playing_match)
    white  = subscribe_and_join_match_channel(match, :player1)
    ref = push white, "move", %{"an" => "f2f3"}
    assert_reply ref, :ok, %{"an" => "f2f3"}
    ref = push white, "move", %{"an" => "f2f3"}
    assert_reply ref, :error, %{"errors" => ["not_white_turn"]}
  end

  test "viewer request move" do
    match = insert(:playing_match)
    white  = subscribe_and_join_match_channel(match, :viewer)
    ref = push white, "move", %{"an" => "f2f3"}
    assert_reply ref, :error, %{"errors" => ["viewer_is_forbidden"]}
  end

  test "fool's mate sample" do
    match = insert(:playing_match)
    white  = subscribe_and_join_match_channel(match, :player1)
    black  = subscribe_and_join_match_channel(match, :player2)
    ref = push white, "move", %{"an" => "f2f3"}
    assert_reply ref, :ok, %{"an" => "f2f3"}
    assert_push "game_state_updated", %{finished: false, fen: "rnbqkbnr/pppppppp/8/8/8/5P2/PPPPP1PP/RNBQKBNR b KQkq - 0 1"}
    ref = push black, "move", %{"an" => "e7e5"}
    assert_reply ref, :ok, %{"an" => "e7e5"}
    assert_push "game_state_updated", %{finished: false, fen: "rnbqkbnr/pppp1ppp/8/4p3/8/5P2/PPPPP1PP/RNBQKBNR w KQkq e6 0 2"}
    ref = push white, "move", %{"an" => "g2g4"}
    assert_reply ref, :ok, %{"an" => "g2g4"}
    assert_push "game_state_updated", %{finished: false, fen: "rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq g3 0 2"}
    ref = push black, "move", %{"an" => "d8h4"}
    assert_reply ref, :ok, %{"an" => "d8h4"}
    assert_push "game_state_updated", %{finished: _finished, fen: "rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3"}
  end

  defp subscribe_and_join_match_channel(match, :player1) do
    credential = ChessApp.Account.get_credential!(match.player1_id)
    subscribe_and_join_match_channel(match, credential)
  end
  defp subscribe_and_join_match_channel(match, :player2) do
    credential = ChessApp.Account.get_credential!(match.player2_id)
    subscribe_and_join_match_channel(match, credential)
  end
  defp subscribe_and_join_match_channel(match, :viewer) do
    credential = insert(:credential)
    subscribe_and_join_match_channel(match, credential)
  end
  defp subscribe_and_join_match_channel(match, credential) do
    {:ok, auth_token} = ChessApp.Account.create_auth_token(credential)
    {:ok, socket} = connect(UserSocket, %{"jwt" => auth_token.jwt})
    {:ok,_reply, socket} = socket
      |> subscribe_and_join(MatchChannel, "match:#{match.id}")
    socket
  end

end
