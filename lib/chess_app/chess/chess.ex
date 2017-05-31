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

  def all_matches_index_page(params) do
    Match
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(params)
  end

  def playing_matches_index_page(params) do
    Match
    |> where([m], m.finished == false and not is_nil(m.player2_id))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(params)
  end

  def waiting_for_opponent_matches_index_page(params) do
    Match
    |> where([m], is_nil(m.player2_id))
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(params)
  end

  def finished_matches_index_page(params) do
    Match
    |> where([finished: true])
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(params)
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

  @doc false
  def join_match(id, %Credential{id: account_id}) when is_binary(account_id) do
    Repo.transaction fn ->
      match = Repo.get(Match, id)
      case match do
        %{player1_id: ^account_id} -> match
        %{player2_id: ^account_id} -> match
        %{player2_id: nil} ->
          match
          |> Match.set_player2_id_changeset(account_id)
          |> Repo.update!
        _ -> match
      end
    end
  end

end
