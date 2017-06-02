defmodule ChessApp.Chess.Board do
  @enforce_keys [:placements,:active,:castling,:enpassant,:halfmove_clock,:fullmove_number]
  defstruct [:placements,:active,:castling,:enpassant,:halfmove_clock,:fullmove_number]
  alias ChessApp.Chess.Board
  alias ChessApp.Chess.Move
  alias ChessApp.Chess.Board.CastlingRights
  import ChessApp.Chess.Board.Macros

  def load(fen) when is_binary(fen) do
    ChessApp.Chess.Board.FenLoader.load(fen)
  end

  def dump!(board = %Board{}) do
    {:ok, fen} = ChessApp.Chess.Board.FenExporter.run(board)
    fen
  end

  def make_move(board = %Board{}, algebraic_notation_move) when is_binary(algebraic_notation_move) do
    with {:ok, move} <- Move.from_algebraic_notation(algebraic_notation_move,board) do
      make_move(board,move)
    end
  end
  def make_move(board = %Board{}, move = %Move{chesspiece: chesspiece, from: from, side: color}) do
    Board.at!(board,from)
    |> case  do
      {^color,^chesspiece} -> update_board(board,move)
      :empty -> {:error, :invalid_move, "Can't move from an empty square"};
      _ -> {:error, :invalid_move, "Not your piece"}
    end
  end

  def at!(%Board{placements: placements}, position) when position in (1..64) do
    idx  = position_to_placements_index(position)
    Enum.at(placements, idx)
  end

  def at!(board = %Board{}, named_position) when is_binary(named_position) do
    {:ok, position} = name_to_square(named_position)
     at!(board, position)
  end

  def parse_piece!("K"), do: {:white, :king}
  def parse_piece!("Q"), do: {:white, :queen}
  def parse_piece!("R"), do: {:white, :rook}
  def parse_piece!("B"), do: {:white, :bishop}
  def parse_piece!("N"), do: {:white, :knight}
  def parse_piece!("P"), do: {:white, :pawn}
  def parse_piece!("k"), do: {:black, :king}
  def parse_piece!("q"), do: {:black, :queen}
  def parse_piece!("r"), do: {:black, :rook}
  def parse_piece!("b"), do: {:black, :bishop}
  def parse_piece!("n"), do: {:black, :knight}
  def parse_piece!("p"), do: {:black, :pawn}

  def parse_piece("K"), do: {:ok, {:white, :king}}
  def parse_piece("Q"), do: {:ok, {:white, :queen}}
  def parse_piece("R"), do: {:ok, {:white, :rook}}
  def parse_piece("B"), do: {:ok, {:white, :bishop}}
  def parse_piece("N"), do: {:ok, {:white, :knight}}
  def parse_piece("P"), do: {:ok, {:white, :pawn}}
  def parse_piece("k"), do: {:ok, {:black, :king}}
  def parse_piece("q"), do: {:ok, {:black, :queen}}
  def parse_piece("r"), do: {:ok, {:black, :rook}}
  def parse_piece("b"), do: {:ok, {:black, :bishop}}
  def parse_piece("n"), do: {:ok, {:black, :knight}}
  def parse_piece("p"), do: {:ok, {:black, :pawn}}

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

  defp update_board(board = %Board{}, move = %Move{}) do
    board
    |> update_fullmove_number(move)
    |> update_active(move)
    |> update_placements(move)
    |> update_halfmove_clock(move)
    |> update_enpassant(move)
    |> update_castling(move)
    |> ok
  end

  defp update_fullmove_number(board = %Board{fullmove_number: fullmove_number},%Move{side: :black}) do
    %{board | fullmove_number: fullmove_number + 1}
  end
  defp update_fullmove_number(board = %Board{},%Move{side: :white}), do: board

  defp update_active(board = %Board{},%Move{side: :black}), do: %{board | active: :white}
  defp update_active(board = %Board{},%Move{side: :white}), do: %{board | active: :black}

  defp update_placements(board = %Board{}, move = %Move{special: :normal}) do
    do_update_placements(board,move)
  end
  defp update_placements(board = %Board{}, move = %Move{special: :castle}) do
    board
    |> do_update_placements(move)
    |> do_update_placements(rook_move_for_castle(move))
  end
  defp update_placements(board = %Board{}, move = %Move{special: :enpassant}) do
    board
    |> do_update_placements(move)
    |> do_captured_piece_at(enpassant_captured_pawn_square(move))
  end
  defp update_placements(board = %Board{}, %Move{special: :promotion, promotion: promotion, from: from, to: to, side: color}) do
    placements = board.placements
      |> List.replace_at(position_to_placements_index(from), :empty)
      |> List.replace_at(position_to_placements_index(to), {color,promotion || :queen})
    %{board | placements: placements}
  end

  defp do_update_placements(board = %Board{placements: placements},%Move{from: from, to: to}) do
    moving_piece = Board.at!(board,from)
    placements = placements
      |> List.replace_at(position_to_placements_index(from), :empty)
      |> List.replace_at(position_to_placements_index(to), moving_piece)
    %{board | placements: placements}
  end
  defp do_captured_piece_at(board = %Board{placements: placements},captured_position)  do
    placements = placements
      |> List.replace_at(captured_position, :empty)
    %{board | placements: placements}
  end

  defp update_halfmove_clock(board = %Board{},%Move{chesspiece: :pawn}), do: %{board | halfmove_clock: 0}
  defp update_halfmove_clock(board = %Board{},%Move{capture: :true}), do: %{board | halfmove_clock: 0}
  defp update_halfmove_clock(board = %Board{halfmove_clock: halfmove_clock},_) do
    %{board | halfmove_clock: halfmove_clock + 1}
  end

  defp update_enpassant(board = %Board{},%Move{chesspiece: :pawn, from: from, to: to}) do
    from_rank = square_rank_index(from)
    to_rank   = square_rank_index(to)
    # if the piece moved two spaces, then the enpassant square is their average
    enpassant = if abs(from_rank - to_rank) == 2 do
      Integer.floor_div(from + to, 2)
    else
      :none
    end
    %{board | enpassant: enpassant}
  end
  defp update_enpassant(board = %Board{},_) do
    %{board | enpassant: :none}
  end

  # short circuit anyone who has no possible castling
  defp update_castling(board = %Board{castling: %CastlingRights{white_kingside: false, white_queenside: false, black_kingside: false, black_queenside: false}},_move) do
    board
  end
  # Reasons castling status would change:
  # 1. Move your king (includes castling)
  defp update_castling(board = %Board{castling: castling},%Move{chesspiece: :king, side: :white}) do
    next_castling = %{ castling | white_kingside: false, white_queenside: false }
    %{ board | castling: next_castling }
  end
  defp update_castling(board = %Board{castling: castling},%Move{chesspiece: :king, side: :black}) do
    next_castling = %{ castling | black_kingside: false, black_queenside: false }
    %{ board | castling: next_castling }
  end
  # 2. Move a rook for the first time
  defp update_castling(board = %Board{castling: castling = %CastlingRights{white_queenside: true}},%Move{chesspiece: :rook, side: :white, from: 1}) do
    next_castling = %{ castling | white_queenside: false }
    %{ board | castling: next_castling }
  end
  defp update_castling(board = %Board{castling: castling = %CastlingRights{white_kingside: true}},%Move{chesspiece: :rook, side: :white, from: 8}) do
    next_castling = %{ castling | white_kingside: false }
    %{ board | castling: next_castling }
  end
  defp update_castling(board = %Board{castling: castling = %CastlingRights{black_queenside: true}},%Move{chesspiece: :rook, side: :black, from: 57}) do
    next_castling = %{ castling | black_queenside: false }
    %{ board | castling: next_castling }
  end
  defp update_castling(board = %Board{castling: castling = %CastlingRights{black_kingside: true}},%Move{chesspiece: :rook, side: :black, from: 64}) do
    next_castling = %{ castling | black_kingside: false }
    %{ board | castling: next_castling }
  end
  # 3. Have a rook captured
  defp update_castling(board = %Board{castling: castling = %CastlingRights{black_queenside: true}},%Move{capture: true, side: :white, to: 57}) do
    next_castling = %{ castling | black_queenside: false }
    %{ board | castling: next_castling }
  end
  defp update_castling(board = %Board{castling: castling = %CastlingRights{black_kingside: true}},%Move{capture: true, side: :white, to: 64}) do
    next_castling = %{ castling | black_kingside: false }
    %{ board | castling: next_castling }
  end
  defp update_castling(board = %Board{castling: castling = %CastlingRights{white_queenside: true}},%Move{capture: true, side: :black, to: 1}) do
    next_castling = %{ castling | white_queenside: false }
    %{ board | castling: next_castling }
  end
  defp update_castling(board = %Board{castling: castling = %CastlingRights{white_kingside: true}},%Move{capture: true, side: :black, to: 8}) do
    next_castling = %{ castling | white_kingside: false }
    %{ board | castling: next_castling }
  end
  defp update_castling(board,_) do
    board
  end

  defp rook_move_for_castle(%Move{from:  5, to:  7}), do: %Move{from:  8, to:  6}
  defp rook_move_for_castle(%Move{from:  5, to:  3}), do: %Move{from:  1, to:  4}
  defp rook_move_for_castle(%Move{from: 61, to: 63}), do: %Move{from: 64, to: 62}
  defp rook_move_for_castle(%Move{from: 61, to: 59}), do: %Move{from: 57, to: 60}

  defp enpassant_captured_pawn_square(%Move{from: from, to: to}) do
    rank = 7 - square_rank_index(from)
    file = square_file_index(to)
    8 * rank + file
  end

  defp position_to_placements_index(position) do
    rank = 7 - square_rank_index(position)
    file = square_file_index(position)
    8 * rank + file
  end

  def ok(board = %Board{}) do
    {:ok, board}
  end

end
