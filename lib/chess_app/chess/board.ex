defmodule ChessApp.Chess.Board do
  @enforce_keys [:placements,:active,:castling,:enpassant,:halfmove_clock,:fullmove_number]
  defstruct [:placements,:active,:castling,:enpassant,:halfmove_clock,:fullmove_number]
  alias ChessApp.Chess.Board

  defmacro is_file(file) do
    quote do: unquote(file) in ~w(a b c d e f g h)
  end

  defmacro is_rank(rank) do
    quote do: unquote(rank) in ~w(1 2 3 4 5 6 7 8)
  end

  def load(fen) when is_binary(fen) do
    ChessApp.Chess.Board.FenLoader.load(fen)
  end

  def at!(board = %Board{placements: placements}, position) when position in (1..64) do
    rank = 7 - square_rank_index(position)
    file = square_file_index(position)
    idx  = 8 * rank + file
    Enum.at(placements, idx)
  end

  def at!(board = %Board{placements: placements}, named_position) when is_binary(named_position) do
    {:ok, position} = name_to_square(named_position)
     at!(board, position)
  end

  def name_to_square!(file,rank) when is_file(file) and is_rank(rank) do
    {:ok, square} = name_to_square(file <> rank)
    square
  end

  def name_to_square!(named_position) do
    {:ok, square} = name_to_square(named_position)
    square
  end

  def name_to_square(named_position) do
    named_position
    |> String.downcase
    |> String.split("",trim: true)
    |> case  do
      [file,rank] when is_file(file) and is_rank(rank) ->
        file_idx = String.to_integer(file, 18) - 10
        rank_idx = String.to_integer(rank, 10) - 1
        square   = (rank_idx) * 8 + (file_idx) + 1
        {:ok, square}
      _ ->
        {:error, :invalid_format}
    end
  end

  def square_to_name(index) when is_integer(index) do
    rank = square_rank_index(index) + ?1
    file = square_file_index(index) + ?a
    name = List.to_string([file,rank])
    {:ok, name}
  end

  defp square_file_index(square), do: Integer.mod(square - 1, 8)
  defp square_rank_index(square), do: Integer.floor_div(square - 1, 8)


end
