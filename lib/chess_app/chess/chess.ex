defmodule ChessApp.Chess do
  @moduledoc """
  The boundary for the Account system.
  """

  import Ecto.Query, warn: false
  alias ChessApp.Repo

  alias ChessApp.Account.Credential
  alias ChessApp.Chess.Match

  def create_match(%Credential{id: id}) do
    %Match{}
    |> Match.registration_changeset(%{player1_id: id})
    |> Repo.insert()
  end

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Repo.all(Match)
  end

  @doc false
  def get_match(id), do: Repo.get(Match, id)

  @doc """
  Gets a single match by id.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!("fe1e7920-63e5-4a34-adb5-f4d188d34829")
      %Match{}

      iex> get_match!("66477356-e402-4175-be95-0777bf31a6a1")
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id)

end
