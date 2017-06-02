defmodule ChessApp.Web.Router do
  use ChessApp.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  scope "/api", ChessApp.Web, as: :api do
    pipe_through :api
    post "/accounts", CredentialController, :create, as: :signup
    post "/auth_tokens", AuthTokenController, :create, as: :auth_token
  end

  scope "/api", ChessApp.Web, as: :api do
    pipe_through [:api,:api_auth]
    post "/matches", MatchController, :create, as: :chess_match
    get "/matches", MatchController, :index, as: :matches
    get "/matches/playing", MatchController, :playing_matches_index, as: :playing_matches
    get "/matches/waiting", MatchController, :waiting_for_opponent_matches_index, as: :waiting_for_opponent_matches
    get "/matches/finished", MatchController, :finished_matches_index, as: :finished_matches
    post "/auth_tokens", AuthTokenController, :create, as: :auth_token
  end

  scope "/", ChessApp.Web do
    pipe_through [:browser,:browser_auth]
    get "/", HomeController, :index
    get "/login", SessionController, :new
    post "/sessions", SessionController, :create
    delete "/sessions", SessionController, :delete
    get "/signup", SignupController, :new
    post "/signups", SignupController, :create
    get "/matches/:id", MatchController, :show, as: :match
  end
end
