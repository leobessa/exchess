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
      state: @starting_game_state,
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
      state: @starting_game_state,
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
      state: @starting_game_state,
      player1_id: ^player1_id, player2_id: ^player2_id
    }
  end

  # test "ping replies with status ok", %{socket: socket} do
  #   ref = push socket, "ping", %{"hello" => "there"}
  #   assert_reply ref, :ok, %{"hello" => "there"}
  # end
  #
  # test "shout broadcasts to match:lobby", %{socket: socket} do
  #   push socket, "shout", %{"hello" => "all"}
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end
  #
  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from! socket, "broadcast", %{"some" => "data"}
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
