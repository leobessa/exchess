defmodule ChessApp.Chess.Move do
  defstruct [:to,:from,:promotion,:chesspiece,:special,:side,:capture]

  alias ChessApp.Chess.Board
  alias ChessApp.Chess.Move
  import ChessApp.Chess.Board.Macros

  def from_algebraic_notation(an,board = %Board{}) do
    codes = String.downcase(an)
      |> String.codepoints
    with {:ok, {from,to,promotion}} <- parse_codes(codes) do
      build_move(board, from, to, promotion)
    else
      {:error, :invalid_format} -> {:error, :invalid_format}
    end
  end

  defp parse_codes([from_file, from_rank, "x", to_file, to_rank]) when is_file(from_file) and is_rank(from_rank) and is_file(to_file) and is_rank(to_rank) do
    parse_codes([from_file, from_rank, to_file, to_rank])
  end
  defp parse_codes([from_file, from_rank, "x", to_file, to_rank, promote]) when is_file(from_file) and is_rank(from_rank) and is_file(to_file) and is_rank(to_rank) do
    parse_codes([from_file, from_rank, to_file, to_rank, promote])
  end
  defp parse_codes([from_file, from_rank, to_file, to_rank]) when is_file(from_file) and is_rank(from_rank) and is_file(to_file) and is_rank(to_rank) do
    {:ok, {Board.name_to_square!(from_file,from_rank), Board.name_to_square!(to_file, to_rank), nil}}
  end
  defp parse_codes([from_file, from_rank, to_file, to_rank, promote]) when is_file(from_file) and is_rank(from_rank) and is_file(to_file) and is_rank(to_rank) do
    {:ok, {_color, promote_piece}} = Board.parse_piece(promote)
    {:ok, {Board.name_to_square!(from_file,from_rank), Board.name_to_square!(to_file, to_rank), promote_piece}}
  end
  defp parse_codes(_other) do
    {:error, :invalid_format}
  end

  defp build_move(board = %Board{active: active, enpassant: enpassant}, from, to, promotion) when is_integer(from) and is_integer(to) do
    case Board.at!(board,from) do
      {^active,piece} ->
        move = %Move{
          to: to, from: from, promotion: promotion,
          chesspiece: piece, side: active,
          special: special_kind({active, piece}, from, to, promotion, enpassant)
        }
        case Board.at!(board,to) do
          {^active,_piece} ->
            {:error, :invalid_move, "Can't capture your own piece"}
          :empty ->
            capture = (move.special == :enpassant)
            {:ok, %{move | capture: capture}}
          {_,_piece} ->
            {:ok, %{move | capture: true}}
        end
      :empty ->
        {:error, :invalid_move, "No piece to move on that square."}
      {_other_color, _piece} ->
        {:error, :invalid_move, "Can't move a piece that isn't yours!"}
    end
  end

  defp special_kind({_, :pawn}, _from, to, nil, to), do: :enpassant
  defp special_kind({_, :pawn}, _, _, promoted, _) when not is_nil(promoted), do: :promotion;
  defp special_kind({:white, :king}, 5, 7, nil, _), do: :castle
  defp special_kind({:white, :king}, 5, 3, nil, _), do: :castle
  defp special_kind({:black, :king}, 61, 63, nil, _), do: :castle
  defp special_kind({:black, :king}, 61, 59, nil, _), do: :castle
  defp special_kind(_, _, _, nil, _), do: :normal

end
