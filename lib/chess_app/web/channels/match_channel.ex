defmodule ChessApp.Web.MatchChannel do
  use ChessApp.Web, :channel

  def join("match:" <> match_id, payload, socket) do
    if authorized?(payload) do
      match = ChessApp.Chess.get_match(match_id)
      socket = assign(socket, :match, match)
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    match = socket.assigns[:match]
    push socket, "game_state_sync", %{state: match.game_state}
   {:noreply, socket}
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

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
