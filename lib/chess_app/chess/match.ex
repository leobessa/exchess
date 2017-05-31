defmodule ChessApp.Chess.Match do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChessApp.Account.Credential

  @initial_game_state "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "matches" do
    belongs_to :player1, Credential
    belongs_to :player2, Credential
    field :game_state, :string, default: @initial_game_state
    field :finished, :boolean, default: false

    timestamps()
  end

  def registration_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:player1_id])
    |> validate_required([:player1_id])
  end

end
