defmodule ChessApp.Chess.Board.FenLoader do
  alias ChessApp.Chess.Board

  def load(fen) when is_binary(fen) do
    [placements,active,castling,enpassant,halfmove_clock,fullmove_number] = String.split(fen," ")
    board = %Board{
      placements: placements(placements),
      active: active(active),
      castling: castling(castling),
      enpassant: enpassant(enpassant),
      halfmove_clock: String.to_integer(halfmove_clock),
      fullmove_number: String.to_integer(fullmove_number),
    }
    {:ok, board}
  end

  defp active("w"), do: :white
  defp active("b"), do: :black

  defp enpassant("-"), do: :none
  defp enpassant(enpassant) when is_binary(enpassant) do
    {:ok, square} = Board.name_to_square(enpassant)
    square
  end

  defp castling(castling) do
    %ChessApp.Chess.Board.CastlingRights{
      white_kingside: String.contains?(castling, "K"),
      white_queenside: String.contains?(castling,"Q"),
      black_kingside: String.contains?(castling, "k"),
      black_queenside: String.contains?(castling, "q")
    }
  end

  defp placements(placements) do
    placements
    |> String.split("/")
    |> Enum.flat_map(fn(rank) ->
      rank
      |> String.codepoints
      |> Enum.map(&piece(&1))
    end)
    |> List.flatten
  end

  defp piece("K"), do: {:white, :king}
  defp piece("Q"), do: {:white, :queen}
  defp piece("R"), do: {:white, :rook}
  defp piece("B"), do: {:white, :bishop}
  defp piece("N"), do: {:white, :knight}
  defp piece("P"), do: {:white, :pawn}
  defp piece("k"), do: {:black, :king}
  defp piece("q"), do: {:black, :queen}
  defp piece("r"), do: {:black, :rook}
  defp piece("b"), do: {:black, :bishop}
  defp piece("n"), do: {:black, :knight}
  defp piece("p"), do: {:black, :pawn}
  defp piece(blanks) when blanks in ~w(1 2 3 4 5 6 7 8) do
    List.duplicate(:empty, String.to_integer(blanks) )
  end
end
