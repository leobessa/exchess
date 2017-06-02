defmodule ChessApp.Chess.Board.FenExporter do
  alias ChessApp.Chess.Board

  def run(board = %Board{}) do
    fen = [
      placements(board.placements),
      active(board.active),
      castling(board.castling),
      enpassant(board.enpassant),
      Integer.to_string(board.halfmove_clock),
      Integer.to_string(board.fullmove_number),
    ]
    |> Enum.join(" ")
    {:ok, fen}
  end

  defp active(:white), do: "w"
  defp active(:black), do: "b"

  def enpassant(:none), do: "-"
  def enpassant(enpassant) when is_integer(enpassant), do: square_to_name(enpassant)

  defp square_to_name(position) do
    idx = position - 1
    file_idx = Integer.mod(idx, 8)
    rank_idx = Integer.floor_div(idx,8) + 1
    file_letter = Enum.at(~w(a b c d e f g h),file_idx)
    "#{file_letter}#{rank_idx}"
  end

  defp castling(castling) do
    result = ""
    result = if castling.white_kingside do result <> "K" else result end
    result = if castling.white_queenside do result <> "Q" else result end
    result = if castling.black_kingside do result <> "k" else result end
    result = if castling.black_queenside do result <> "q" else result end
    result
  end

  defp placements(placements) do
    placements
    |> Enum.chunk(8)
    |> Enum.map_join("/", &rank_line(&1))
  end

  defp rank_line(placements) do
    placements
    |> Enum.map_join("", &piece(&1))
    |> compact_emptys
  end

  defp compact_emptys(s) do
    s
    |> String.replace("        ","8")
    |> String.replace("       ","7")
    |> String.replace("      ","6")
    |> String.replace("     ","5")
    |> String.replace("    ","4")
    |> String.replace("   ","3")
    |> String.replace("  ","2")
    |> String.replace(" ","1")
  end

  defp piece({:white, :king}), do: "K"
  defp piece({:white, :queen}), do: "Q"
  defp piece({:white, :rook}), do: "R"
  defp piece({:white, :bishop}), do: "B"
  defp piece({:white, :knight}), do: "N"
  defp piece({:white, :pawn}), do: "P"

  defp piece({:black, :king}), do: "k"
  defp piece({:black, :queen}), do: "q"
  defp piece({:black, :rook}), do: "r"
  defp piece({:black, :bishop}), do: "b"
  defp piece({:black, :knight}), do: "n"
  defp piece({:black, :pawn}), do: "p"
  defp piece(:empty), do: " "

end
