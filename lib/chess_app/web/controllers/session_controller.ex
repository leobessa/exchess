defmodule ChessApp.Web.SessionController do
  use ChessApp.Web, :controller
  plug :scrub_params, "session" when action in [:create]
  action_fallback ChessApp.Web.FallbackController

  def new(conn, params = %{}) do
    request_path = params |> Map.get("redirect_to","/")
    conn
    |> assign(:redirect_to, request_path)
    |> assign(:title, "Login")
    |> render("new.html")
  end

  def create(conn, params = %{"session" => %{"username" => username, "password" => password}}) do
    case ChessApp.Account.authenticate(username,password) do
      {:ok, credential} ->
        request_path = params |> Map.get("redirect_to","/")
        conn
        |> put_flash(:info, "Logged in.")
        |> Guardian.Plug.sign_in(credential)
        |> redirect(to: request_path)
      {:error, :invalid_credential} ->
        next_params = params |> Map.take(["redirect_to"])
        conn
        |> put_flash(:error, "invalid credential")
        |> redirect(to: session_path(conn, :new, next_params))
    end
  end

  def delete(conn, _) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end

  def unauthenticated(conn, %{}) do
    request_path = conn.request_path
    params = case request_path do
      "/" -> %{}
      _ -> %{"redirect_to" => request_path}
    end

    conn |> redirect(to: session_path(conn, :new, params))
  end

end
