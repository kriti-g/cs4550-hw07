defmodule UserStories.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :response, Ecto.Enum, values: [:Pending, :Yes, :No]
    belongs_to :event, UserStories.Events.Event
    belongs_to :user, UserStories.Users.User, foreign_key: :email, references: :email

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:response, :event_id, :user_email])
    |> validate_required([:response, :event_id, :user_email])
  end
end
