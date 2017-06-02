defmodule ChessApp.Web.SignupController do
  use ChessApp.Web, :controller
  alias ChessApp.Account
  alias ChessApp.Account.Credential
  plug :scrub_params, "password" when action in [:create]
  action_fallback ChessApp.Web.FallbackController

  def new(conn, _params = %{}) do
    conn
    |> render("new.html")
  end

  def create(conn, params = %{}) do
    with {:ok, %Credential{}} <- Account.create_credential(params) do
      conn
      |> put_flash(:info, "Sign Up Successful")
      |> redirect(to: home_path(conn, :index))
    end
  end

end
