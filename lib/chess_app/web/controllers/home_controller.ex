defmodule ChessApp.Web.HomeController do
  use ChessApp.Web, :controller
  action_fallback ChessApp.Web.FallbackController
  plug Guardian.Plug.EnsureAuthenticated, handler: ChessApp.Web.SessionController

  def index(conn, _params) do
    credential = Guardian.Plug.current_resource(conn)
    {:ok, auth_token} = ChessApp.Account.create_auth_token(credential)
    conn
    |> assign(:jwt, auth_token.jwt)
    |> render("index.html")
  end

end
