defmodule ChessApp.Web.MatchController do
  use ChessApp.Web, :controller

  alias ChessApp.Chess
  alias ChessApp.Chess.Match

  action_fallback ChessApp.Web.FallbackController
  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def create(conn, _params) do
    credentials = Guardian.Plug.current_resource(conn)
    with {:ok, %Match{} = match} <- Chess.create_match(credentials) do
      conn
      |> put_status(:created)
      |> render("show.json", match: match)
    end
  end

  def index(conn, _params) do
    matches = Chess.list_matches()
    conn
    |> put_status(:ok)
    |> render("index.json", matches: matches)
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> json(%{errors: ["Authentication required"]})
  end

end
