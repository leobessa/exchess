defmodule ChessApp.Chess.Board.CastlingRights do
  @enforce_keys [:white_kingside,:white_queenside,:black_kingside,:black_queenside]
  defstruct [:white_kingside,:white_queenside,:black_kingside,:black_queenside]
end
