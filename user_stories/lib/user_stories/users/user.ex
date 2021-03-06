defmodule UserStories.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :photo_hash, :string

    has_many :events, UserStories.Events.Event, on_delete: :delete_all
    has_many :comments, UserStories.Comments.Comment, on_delete: :delete_all
    has_many :invites, UserStories.Invites.Invite, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :photo_hash])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
