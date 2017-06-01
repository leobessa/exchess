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

end
