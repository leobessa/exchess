defmodule ChessApp.Chess.Board.FenExporterTest do
  use ExUnit.Case
  alias ChessApp.Chess.Board
  alias ChessApp.Chess.Board.FenExporter

  test "export starting position" do
    {:ok, result} = FenExporter.run(%Board{
      active: :white,
      castling: %{
        white_kingside: true, white_queenside: true,
        black_kingside: true, black_queenside: true
      },
      enpassant: :none,
      halfmove_clock: 0,
      fullmove_number: 1,
      placements: [
        {:black, :rook}, {:black, :knight}, {:black, :bishop}, {:black, :queen}, {:black, :king}, {:black, :bishop}, {:black, :knight}, {:black, :rook},
        {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn},
        :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
        :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
        :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
        :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
        {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn},
        {:white, :rook}, {:white, :knight}, {:white, :bishop}, {:white, :queen}, {:white, :king}, {:white, :bishop}, {:white, :knight}, {:white, :rook}
      ]
    })
    assert result == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  end

  test "export sample" do
    {:ok, result} = FenExporter.run(%Board{
      active: :black,
      castling: %{
        white_kingside: true, white_queenside: true,
        black_kingside: true, black_queenside: true
      },
      enpassant: 21,
      halfmove_clock: 0,
      fullmove_number: 1,
      placements: [
        {:black, :rook}, {:black, :knight}, {:black, :bishop}, {:black, :queen}, {:black, :king}, {:black, :bishop}, {:black, :knight}, {:black, :rook},
        {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn},
        :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
        :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
        :empty, :empty, :empty, :empty, {:white, :pawn}, :empty, :empty, :empty,
        :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
        {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, :empty, {:white, :pawn}, {:white, :pawn}, {:white, :pawn},
        {:white, :rook}, {:white, :knight}, {:white, :bishop}, {:white, :queen}, {:white, :king}, {:white, :bishop}, {:white, :knight}, {:white, :rook}
      ]
    })
    assert result == "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
  end
end
