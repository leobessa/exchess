defmodule ChessApp.ChessTest do
  use ChessApp.DataCase

  alias ChessApp.Chess

  import ChessApp.Factory

  describe "update_fen" do
    test "should upated database" do
      next_state = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
      match = insert(:match)
      {:ok, %{fen: ^next_state}} = Chess.update_fen(match,next_state)
      assert Chess.get_match(match.id).fen == next_state
    end
    test "should broadcast fen to match channel" do
      next_state = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
      match = insert(:match)
      topic = "match:#{match.id}"
      ChessApp.Web.Endpoint.subscribe(topic)
      {:ok, match} = Chess.update_fen(match,next_state)
      assert_receive %Phoenix.Socket.Broadcast{
        topic: ^topic,
        event: "game_state_updated",
        payload: ^match
      }
    end
  end
end
