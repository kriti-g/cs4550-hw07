defmodule UserStories.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :" body", :text
      add :" event_id", references(:events, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:comments, [: event_id])
    create index(:comments, [:user_id])
  end
end
