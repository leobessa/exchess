defmodule ChessApp.Chess.Board.Macros do
  defmacro is_file(file) do
    quote do: unquote(file) in ~w(a b c d e f g h)
  end

  defmacro is_rank(rank) do
    quote do: unquote(rank) in ~w(1 2 3 4 5 6 7 8)
  end
end
