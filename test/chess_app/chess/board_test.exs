defmodule ChessApp.Chess.BoardTest do
  use ExUnit.Case, async: true
  alias ChessApp.Chess.Board

  describe "square_to_name <-> name_to_square" do
    test "with downcased names" do
      for square <- 1..64  do
        {:ok, name} = Board.square_to_name(square)
        {:ok, result} = Board.name_to_square(name)
        assert result == square
      end
    end
    test "with upcased names" do
      for square <- 1..64  do
        {:ok, name} = Board.square_to_name(square)
        {:ok, result} = Board.name_to_square(String.upcase(name))
        assert result == square
      end
    end
  end

  describe "square_to_name" do
    test "with 1" do
      assert {:ok, "a1"} = Board.square_to_name(1)
    end
    test "with 52" do
      assert {:ok, "d7"} = Board.square_to_name(52)
    end
    test "with 34" do
      assert {:ok, "b5"} = Board.square_to_name(34)
    end
    test "with 64" do
      assert {:ok, "h8"} = Board.square_to_name(64)
    end
  end
  describe "name_to_square" do
    test "with 'a1'" do
      assert {:ok, 1} = Board.name_to_square("a1")
    end
    test "with 'b1'" do
      assert {:ok, 2} = Board.name_to_square("b1")
    end
    test "with 'A2'" do
      assert {:ok, 9} = Board.name_to_square("A2")
    end
    test "with 'd7'" do
      assert {:ok, 52} = Board.name_to_square("d7")
    end
    test "with 'a8'" do
      assert {:ok, 57} = Board.name_to_square("a8")
    end
    test "with 'h8'" do
      assert {:ok, 64} = Board.name_to_square("h8")
    end
  end

  describe "at" do
    test "with d7 on 'r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R'" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      assert {:white,:queen} == Board.at!(board, "d7")
    end
    test "with a1 on 'r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R'" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      assert {:white,:rook} == Board.at!(board, "a1")
    end
    test "with h8 on 'r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R'" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      assert {:black,:rook} == Board.at!(board, "h8")
    end
    test "with b5 on 'r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R'" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      assert {:white,:bishop} == Board.at!(board, "b5")
    end
  end

  describe "make_move" do
    test "d7g7 on 'r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12'" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      {:ok, result} = Board.make_move(board, "d7g7")
      assert result.halfmove_clock == 0
    end
    test "e2e4 on 'r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 5 12'" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 5 12")
      assert {:error, :invalid_move, _} = Board.make_move(board, "e2e4")
    end
    test "a8b8 on 'r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 5 12'" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 5 12")
      assert {:error, :invalid_move, _} = Board.make_move(board, "a8b8")
    end
  end
  describe "castling on make_move" do
    test "white castling on queen side" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      {:ok, result} = Board.make_move(board, "e1c1")
      assert Board.dump!(result) == "r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/2KR3R b kq - 1 12"
    end
    test "white castling on king side" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      {:ok, result} = Board.make_move(board, "e1g1")
      assert Board.dump!(result) == "r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R4RK1 b kq - 1 12"
    end
    test "black castling on queen side" do
      {:ok, board} = Board.load("r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 12")
      {:ok, result} = Board.make_move(board, "e8c8")
      assert Board.dump!(result) == "2kr3r/8/8/8/8/8/8/R3K2R w KQ - 1 13"
    end
    test "black castling on king side" do
      {:ok, board} = Board.load("r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 12")
      {:ok, result} = Board.make_move(board, "e8g8")
      assert Board.dump!(result) == "r4rk1/8/8/8/8/8/8/R3K2R w KQ - 1 13"
    end
    test "castling rights are lost after white king moved" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      {:ok, result} = Board.make_move(board, "e1d1")
      assert result.castling == %ChessApp.Chess.Board.CastlingRights{
        white_kingside: false, white_queenside: false,
        black_kingside: true, black_queenside: true
      }
    end
    test "castling rights are lost after black king moved" do
      {:ok, board} = Board.load("r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 12")
      {:ok, result} = Board.make_move(board, "e8d8")
      assert result.castling == %ChessApp.Chess.Board.CastlingRights{
        white_kingside: true, white_queenside: true,
        black_kingside: false, black_queenside: false
      }
    end
  end
  describe "en_passant on make_move" do
    test "captures piece" do
      {:ok, board} = Board.load("rnbqkbnr/p1pppppp/8/8/1pPP4/5N2/PP2PPPP/RNBQKB1R b KQkq c3 0 3")
      {:ok, result} = Board.make_move(board, "b4c3")
      assert Board.dump!(result) == "rnbqkbnr/p1pppppp/8/8/3P4/2p2N2/PP2PPPP/RNBQKB1R w KQkq - 0 4"
    end
  end

  describe "make_move updates en_passant" do
    test "black pawn moving 2 ranks" do
      {:ok, board} = Board.load("rnbqkb1r/pppppppp/5n2/3P4/8/8/PPP1PPPP/RNBQKBNR b KQkq - 0 2")
      {:ok, result} = Board.make_move(board, "c7c5")
      assert Board.dump!(result) == "rnbqkb1r/pp1ppppp/5n2/2pP4/8/8/PPP1PPPP/RNBQKBNR w KQkq c6 0 3"
    end
  end

  describe "make_move with promotion" do
    test "promotion to queen" do
      {:ok, board} = Board.load("r4knr/2PQ2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R w KQkq - 0 12")
      {:ok, result} = Board.make_move(board, "c7c8q")
      assert Board.dump!(result) == "r1Q2knr/3Q2pp/5p2/1B6/4P3/P4N2/P1P2PPP/R3K2R b KQkq - 0 12"
    end
  end

  describe "parse_piece" do
    test "parse 'q'" do
      {:black, :queen} = Board.parse_piece!("q")
    end
    test "parse 'Q'" do
      {:white, :queen} = Board.parse_piece!("Q")
    end
  end

end
