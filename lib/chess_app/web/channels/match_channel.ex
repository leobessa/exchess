defmodule ChessApp.Web.MatchChannel do
  use ChessApp.Web, :channel
  import Guardian.Phoenix.Socket
  alias ChessApp.Chess.Board
  alias ChessApp.Chess.Match
  require Logger

  def join("match:" <> match_id, payload, socket) do
    if authorized?(payload) do
      credential = current_resource(socket)
      {:ok, match} = ChessApp.Chess.join_match(match_id, credential)
      socket = assign(socket, :match, match)
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    match = socket.assigns[:match]
    push socket, "game_state_sync", %{
      fen: match.fen,
      player1_id: match.player1_id,
      player2_id: match.player2_id,
      finished: match.finished,
      is_current_player: is_current_player(socket,match)
    }

   {:noreply, socket}
  end

  def handle_in("status", _params, socket) do
    match = socket.assigns[:match]
    reply = {:ok,%{
      fen: match.fen,
      player1_id: match.player1_id,
      player2_id: match.player2_id,
      finished: match.finished,
      is_current_player: is_current_player(socket,match)
    }}
    {:reply, reply, socket}
  end

  def handle_in("move", %{"an" => move}, socket) do
    match = socket.assigns[:match]
    reply = with {:ok, board}  <- Board.load(match.fen),
      :ok <- authorize_turn_move(board,role(socket, match)),
      {:ok, result} <- Board.make_move(board, move) do
        {:ok, match} = ChessApp.Chess.update_fen(match, result)
        Logger.debug("match_updated #{inspect(match)}")
        {:ok, %{"an" => move}}
    else
      {:error, :invalid_move, description} ->
        {:ok, %{"errors" => ["invalid_move"], "description" => description}}
      {:error, %{"errors" => errors}} ->
        {:ok, %{"errors" => errors}}
    end
    {:reply, reply, socket}
  end

  defp role(socket, _match = %{player1_id: player1_id, player2_id: player2_id}) do
    credential = current_resource(socket)
    case credential.id do
      ^player1_id when not is_nil(player1_id) -> :white
      ^player2_id when not is_nil(player2_id) -> :black
      _ -> :viewer
    end
  end

  intercept ["game_state_updated"]

  def handle_out(event_name = "game_state_updated", match = %Match{}, socket) do
    socket = assign(socket, :match, match)
    push socket, event_name, %{finished: match.finished, fen: match.fen, is_current_player: is_current_player(socket,match)}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def is_current_player(_socket,_match = %{finished: true}) do
    false
  end
  def is_current_player(socket,match = %{finished: false}) do
    {:ok, %Board{active: active}} = Board.load(match.fen)
    active == role(socket, match)
  end

  defp authorize_turn_move(%Board{}, :viewer) do
    {:error, %{"errors" => ["viewer_is_forbidden"]}}
  end
  defp authorize_turn_move(%Board{active: active}, _role = active), do: :ok
  defp authorize_turn_move(%Board{active: active}, role) when active != role and role in [:white,:black] do
    {:error, %{"errors" => ["not_#{role}_turn"]}}
  end

end
