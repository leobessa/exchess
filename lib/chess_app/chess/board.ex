defmodule ChessApp.Chess.Board do
  @enforce_keys [:placements,:active,:castling,:enpassant,:halfmove_clock,:fullmove_number]
  defstruct [:placements,:active,:castling,:enpassant,:halfmove_clock,:fullmove_number]

end
