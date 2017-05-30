defmodule ChessApp.Web.Router do
  use ChessApp.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
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
    post "/auth_tokens", AuthTokenController, :create, as: :auth_token
  end
end
