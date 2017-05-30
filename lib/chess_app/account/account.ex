defmodule ChessApp.Account do
  @moduledoc """
  The boundary for the Account system.
  """

  import Ecto.Query, warn: false
  alias ChessApp.Repo

  alias ChessApp.Account.Credential
  alias ChessApp.Account.AuthToken

  def create_auth_token(username, password) do
    with (%Credential{} = credential) <- get_credential_by_username(username),
         true                         <- Credential.password_match?(credential,password) do
        AuthToken.from_credential(credential)
    else
      _ -> {:error, :invalid_credential}
    end
  end

  @doc """
  Returns the list of credentials.

  ## Examples

      iex> list_credentials()
      [%Credential{}, ...]

  """
  def list_credentials do
    Repo.all(Credential)
  end

  @doc false
  def get_credential(id), do: Repo.get(Credential, id)

  @doc """
  Gets a single credential by id.

  Raises `Ecto.NoResultsError` if the Credential does not exist.

  ## Examples

      iex> get_credential!("fe1e7920-63e5-4a34-adb5-f4d188d34829")
      %Credential{}

      iex> get_credential!("66477356-e402-4175-be95-0777bf31a6a1")
      ** (Ecto.NoResultsError)

  """
  def get_credential!(id), do: Repo.get!(Credential, id)

  @doc """
  Gets a single credential by username.

  Raises `Ecto.NoResultsError` if the Credential does not exist.

  ## Examples

      iex> get_credential_by_username("jon")
      %Credential{}

      iex> get_credential_by_username("sam")
      ** (Ecto.NoResultsError)

  """
  def get_credential_by_username(username), do: Repo.get_by(Credential, [username: username])

  @doc """
  Creates a credential.

  ## Examples

      iex> create_credential(%{username: "jon", password: "secret"})
      {:ok, %Credential{}}

      iex> create_credential(%{username: "jon"})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.registration_changeset(attrs)
    |> Repo.insert()
  end

end
