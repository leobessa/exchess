defmodule ChessApp.ChessTest do
  use ChessApp.DataCase

  alias ChessApp.Chess

  import ChessApp.Factory

  describe "update_game_state" do
    test "should upated database" do
      next_state = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
      match = insert(:match)
      {:ok, %{game_state: ^next_state}} = Chess.update_game_state(match,next_state)
      assert Chess.get_match(match.id).game_state == next_state
    end
    test "should broadcast game_state to match channel" do
      next_state = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
      match = insert(:match)
      topic = "match:#{match.id}"
      ChessApp.Web.Endpoint.subscribe(topic)
      {:ok, _} = Chess.update_game_state(match,next_state)
      assert_receive %Phoenix.Socket.Broadcast{
        topic: ^topic,
        event: "game_state_updated",
        payload: %{fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"}
      }
    end
  end
end
