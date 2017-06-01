defmodule ChessApp.Chess.Board.FenLoaderTest do
  use ExUnit.Case, async: true
  alias ChessApp.Chess.Board
  alias ChessApp.Chess.Board.FenLoader

  test "load starting position" do
    {:ok, %Board{} = board} = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    |> FenLoader.load
    assert board.active == :white
    assert board.castling.white_kingside == true
    assert board.castling.white_queenside == true
    assert board.castling.black_kingside == true
    assert board.castling.black_queenside == true
    assert board.enpassant == :none
    assert board.halfmove_clock == 0
    assert board.fullmove_number == 1
    assert length(board.placements) == 64
    assert board.placements == [
      {:black, :rook}, {:black, :knight}, {:black, :bishop}, {:black, :queen}, {:black, :king}, {:black, :bishop}, {:black, :knight}, {:black, :rook},
      {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn},
      :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
      :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
      :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
      :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
      {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn},
      {:white, :rook}, {:white, :knight}, {:white, :bishop}, {:white, :queen}, {:white, :king}, {:white, :bishop}, {:white, :knight}, {:white, :rook}
    ]
  end

  test "load sample data" do
    {:ok, %Board{} = board} = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
    |> FenLoader.load
    assert board.active == :black
    assert board.castling.white_kingside == true
    assert board.castling.white_queenside == true
    assert board.castling.black_kingside == true
    assert board.castling.black_queenside == true
    assert board.enpassant == 21
    assert board.halfmove_clock == 0
    assert board.fullmove_number == 1
    assert length(board.placements) == 64
    assert board.placements == [
      {:black, :rook}, {:black, :knight}, {:black, :bishop}, {:black, :queen}, {:black, :king}, {:black, :bishop}, {:black, :knight}, {:black, :rook},
      {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn},
      :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
      :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
      :empty, :empty, :empty, :empty, {:white, :pawn}, :empty, :empty, :empty,
      :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
      {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, :empty, {:white, :pawn}, {:white, :pawn}, {:white, :pawn},
      {:white, :rook}, {:white, :knight}, {:white, :bishop}, {:white, :queen}, {:white, :king}, {:white, :bishop}, {:white, :knight}, {:white, :rook}
    ]
  end
end
