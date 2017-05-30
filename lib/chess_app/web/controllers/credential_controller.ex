defmodule ChessApp.Web.CredentialController do
  use ChessApp.Web, :controller

  alias ChessApp.Account
  alias ChessApp.Account.Credential

  action_fallback ChessApp.Web.FallbackController

  def create(conn, %{"account" => params}) do
    with {:ok, %Credential{} = credential} <- Account.create_credential(params) do
      conn
      |> put_status(:created)
      |> render("show.json", credential: credential)
    end
  end

end
