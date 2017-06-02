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
      fen: match.game_state,
      player1_id: match.player1_id,
      player2_id: match.player2_id,
      finished: match.finished
    }

   {:noreply, socket}
  end

  def handle_in("status", _params, socket) do
    match = socket.assigns[:match]
    reply = {:ok,%{
      fen: match.game_state,
      player1_id: match.player1_id,
      player2_id: match.player2_id,
      finished: match.finished
    }}
    {:reply, reply, socket}
  end

  def handle_in("move", %{"an" => move}, socket) do
    match = %{player1_id: player1_id, player2_id: player2_id} = socket.assigns[:match]
    credential = current_resource(socket)
    role = case credential.id do
      ^player1_id when not is_nil(player1_id) -> :white
      ^player2_id when not is_nil(player2_id) -> :black
      _ -> :viewer
    end
    reply = with {:ok, board}  <- Board.load(match.game_state),
      :ok <- authorize_turn_move(board,role),
      {:ok, result} <- Board.make_move(board, move) do
        {:ok, match} = ChessApp.Chess.update_game_state(match, result)
        Logger.debug("match_updated #{inspect(match)}")
        {:ok, %{"an" => move}}
    end
    {:reply, reply, socket}
  end

  defp authorize_turn_move(%Board{}, :viewer) do
    {:error, %{"errors" => ["viewer_is_forbidden"]}}
  end
  defp authorize_turn_move(%Board{active: active}, _role = active), do: :ok
  defp authorize_turn_move(%Board{active: active}, role) when active != role and role in [:white,:black] do
    {:error, %{"errors" => ["not_#{role}_turn"]}}
  end

  # # Channels can be used in a request/response fashion
  # # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end
  #
  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (match:lobby).
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end
  intercept ["game_state_updated"]

  def handle_out(event_name = "game_state_updated", match = %Match{}, socket) do
    socket = assign(socket, :match, match)
    push socket, event_name, %{finished: match.finished, fen: match.game_state}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
