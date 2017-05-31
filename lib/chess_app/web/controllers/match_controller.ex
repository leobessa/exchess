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

  def index(conn, params) do
    page = Chess.all_matches_index_page(params)
    conn
    |> put_status(:ok)
    |> Scrivener.Headers.paginate(page)
    |> render("index.json", matches: page.entries)
  end

  def playing_matches_index(conn, params) do
    page = Chess.playing_matches_index_page(params)
    conn
    |> put_status(:ok)
    |> Scrivener.Headers.paginate(page)
    |> render("index.json", matches: page.entries)
  end

  def waiting_for_opponent_matches_index(conn, params) do
    page = Chess.waiting_for_opponent_matches_index_page(params)
    conn
    |> put_status(:ok)
    |> Scrivener.Headers.paginate(page)
    |> render("index.json", matches: page.entries)
  end

  def finished_matches_index(conn, params) do
    page = Chess.finished_matches_index_page(params)
    conn
    |> put_status(:ok)
    |> Scrivener.Headers.paginate(page)
    |> render("index.json", matches: page.entries)
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> json(%{errors: ["Authentication required"]})
  end

end
