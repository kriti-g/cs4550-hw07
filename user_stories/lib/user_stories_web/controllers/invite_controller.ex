defmodule UserStoriesWeb.InviteController do
  use UserStoriesWeb, :controller

  alias UserStories.Invites
  alias UserStories.Invites.Invite
  alias UserStories.Users
  alias UserStories.Photos
  alias UserStories.Events

  plug :fetch_invite when action in [:show, :edit, :update, :delete]
  plug :require_invitee when action in [:edit, :update]
  plug :require_owner when action in [:delete]

  def fetch_invite(conn, _args) do
    id = conn.params["id"]
    inv = Invites.get_invite!(id)
    assign(conn, :invite, inv)
  end

  def require_owner(conn, _args) do
   user = conn.assigns[:current_user]
   inv = conn.assigns[:invite]
   event = Events.get_event!(inv.event_id)

   if user.id == event.user_id do
     conn
   else
     conn
     |> put_flash(:error, "You don't have access to that.")
     |> redirect(to: Routes.page_path(conn, :index))
     |> halt()
   end
 end

 def require_invitee(conn, _args) do
  user = conn.assigns[:current_user]
  inv = conn.assigns[:invite]

  if user.id == inv.user_id  do
    conn
  else
    conn
    |> put_flash(:error, "You don't have access to that.")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end
end

  def index(conn, _params) do
    invites = Invites.list_invites()
    render(conn, "index.html", invites: invites)
  end

  def new(conn, _params) do
    changeset = Invites.change_invite(%Invite{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invite" => invite_params}) do
    email = invite_params["user_email"]
    user = Users.get_user_by_email(email)
    [link, new_invite_params] = if user do
      lin = "http://events.gkriti.art/events/" <> to_string(invite_params["event_id"])
      [lin, Map.put(invite_params, "user_id", user.id)]
    else
      hash = Photos.get_default()
      new_user = %{
        name: "---CHANGE THIS TO YOUR NAME---",
        email: email,
        photo_hash: hash
      }
      {:ok, created} = Users.create_user(new_user)
      lin = "http://events.gkriti.art/users/" <>  to_string(created.id) <> "/edit"
      [lin, Map.put(invite_params, "user_id", created.id)]
    end

    case Invites.create_invite(new_invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Direct your friend to this link: " <> link)
        |> redirect(to: Routes.invite_path(conn, :show, invite))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    invite = conn.assigns[:invite]
    render(conn, "show.html", invite: invite)
  end

  def edit(conn, %{"id" => _id}) do
    invite = conn.assigns[:invite]
    changeset = Invites.change_invite(invite)
    render(conn, "edit.html", invite: invite, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "invite" => invite_params}) do
    invite = conn.assigns[:invite]
    event = Events.get_event!(invite.event_id)

    case Invites.update_invite(invite, invite_params) do
      {:ok, _invite} ->
        conn
        |> put_flash(:info, "Successfully responded.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invite: invite, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    invite = conn.assigns[:invite]
    {:ok, _invite} = Invites.delete_invite(invite)

    conn
    |> put_flash(:info, "Invite deleted successfully.")
    |> redirect(to: Routes.invite_path(conn, :index))
  end
end
