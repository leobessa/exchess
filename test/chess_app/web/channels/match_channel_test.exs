defmodule ChessApp.Web.MatchChannelTest do
  use ChessApp.Web.ChannelCase

  alias ChessApp.Web.MatchChannel
  alias ChessApp.Web.UserSocket
  import ChessApp.Factory

  setup do
    %{username: username} = build(:credential) |> with_password("secret") |> insert
    {:ok, auth_token} = ChessApp.Account.create_auth_token(username, "secret")
    {:ok, socket} = connect(UserSocket, %{"jwt" => auth_token.jwt})
    match = insert(:match, %{player1_id: auth_token.account_id})
    {:ok, socket: socket, auth_token: auth_token, match: match}
  end

  test "initial state of the match is sent after join", %{socket: socket, match: match} do
    socket
      |> subscribe_and_join(MatchChannel, "match:#{match.id}")
    assert_push "game_state_sync", %{state: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"}
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
