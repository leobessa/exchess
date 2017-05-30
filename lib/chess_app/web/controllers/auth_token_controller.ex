defmodule ChessApp.Web.AuthTokenController do
  use ChessApp.Web, :controller

  alias ChessApp.Account
  alias ChessApp.Account.AuthToken

  action_fallback ChessApp.Web.FallbackController

  def create(conn, %{"account" => %{"username" => username, "password" => password}}) do
    with {:ok, %AuthToken{} = auth_token} <- Account.create_auth_token(username,password) do
      conn
      |> put_status(:created)
      |> render("show.json", auth_token: auth_token)
    else
      {:error, :invalid_credential} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ["Invalid credential."]})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{errors: ["Invalid parameters."]})
  end

end
