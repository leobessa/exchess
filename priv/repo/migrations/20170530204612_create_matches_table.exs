defmodule ChessApp.Repo.Migrations.CreateMatchesTable do
  use Ecto.Migration

  def change do
    create table(:matches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :player1_id, references(:account_credentials, type: :binary_id)
      add :player2_id, references(:account_credentials, type: :binary_id)
      add :game_state, :string
      add :finished, :boolean, default: false

      timestamps()
    end
    create index(:matches, [:player1_id])
    create index(:matches, [:player2_id])
    create index(:matches, [:finished])
  end
end
