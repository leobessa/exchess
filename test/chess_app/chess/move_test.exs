defmodule ChessApp.Chess.MoveTest do
  use ExUnit.Case, async: true
  alias ChessApp.Chess.Move
  alias ChessApp.Chess.Board

  describe "from_algebraic_notation" do
    setup do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      [board: board]
    end
    test "with 'A2A4' ", %{board: board} do
      {:ok, move}  = Move.from_algebraic_notation("A2A4",board)
      assert move == %Move{
        to: Board.name_to_square!("a4"),
        from: Board.name_to_square!("a2"),
        promotion: nil,
        chesspiece: :pawn,
        special: :normal,
        side: :white,
        capture: false
      }
    end
    test "with 'd7g7'", %{board: board} do
      {:ok, move}  = Move.from_algebraic_notation("d7g7",board)
      assert move == %Move{
        from: Board.name_to_square!("d7"),
        to: Board.name_to_square!("g7"),
        promotion: nil,
        chesspiece: :queen,
        special: :normal,
        side: :white,
        capture: true
      }
    end
    test "with 'd7xg7'", %{board: board} do
      assert Move.from_algebraic_notation("d7g7",board) == Move.from_algebraic_notation("d7xg7",board)
    end
    test "with 'd7c7' returns invalid_move error", %{board: board} do
      assert {:error, :invalid_move, _} = Move.from_algebraic_notation("d7c7",board)
    end
    test "with '(none)' returns invalid_format error", %{board: board} do
      assert {:error, :invalid_format} = Move.from_algebraic_notation("(none)",board)
    end
    test "with 'i2j4' returns invalid_format error", %{board: board} do
      assert {:error, :invalid_format} = Move.from_algebraic_notation("i2j4",board)
    end
    test "with 'adsfas' returns invalid_format error", %{board: board} do
      assert {:error, :invalid_format} = Move.from_algebraic_notation("adsfas",board)
    end
    test "with '0000' returns invalid_format error", %{board: board} do
      assert {:error, :invalid_format} = Move.from_algebraic_notation("0000",board)
    end
    test "enpassant" do
      {:ok, board} = Board.load("rnbqkbnr/p1pppppp/8/8/1pPP4/5N2/PP2PPPP/RNBQKB1R b KQkq c3 0 3")
      {:ok, en_passant_move} = Move.from_algebraic_notation("b4c3",board)
      assert %Move{
        side: :black, special: :enpassant, capture: true, chesspiece: :pawn
      } = en_passant_move
    end
  end

end
