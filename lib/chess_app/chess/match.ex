defmodule ChessApp.Chess.Match do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChessApp.Account.Credential

  @initial_fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "matches" do
    belongs_to :player1, Credential
    belongs_to :player2, Credential
    field :fen, :string, default: @initial_fen
    field :finished, :boolean, default: false

    timestamps()
  end

  def registration_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:player1_id])
    |> validate_required([:player1_id])
  end

  def set_player2_id_changeset(model, player2_id) do
    model
    |> change()
    |> put_change(:player2_id, player2_id)
  end

  def set_fen_changeset(model, fen) do
    model
    |> change()
    |> put_change(:fen, fen)
  end

end
