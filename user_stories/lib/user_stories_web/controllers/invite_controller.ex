defmodule UserStoriesWeb.InviteController do
  use UserStoriesWeb, :controller

  alias UserStories.Invites
  alias UserStories.Invites.Invite
  alias UserStories.Users

  def index(conn, _params) do
    invites = Invites.list_invites()
    render(conn, "index.html", invites: invites)
  end

  def new(conn, _params) do
    changeset = Invites.change_invite(%Invite{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invite" => invite_params}) do
    IO.inspect(invite_params)
    email = invite_params["user_email"]
    user = Users.get_user_by_email(email)
    [link, new_invite_params] = if user do
      lin = "http://events.gkriti.art/events/" <> to_string(invite_params["event_id"])
      [lin, Map.put(invite_params, "user_id", user.id)]
    else
      new_user = %{
        name: "---CHANGE THIS TO YOUR NAME---",
        email: email,
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

  def show(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    render(conn, "show.html", invite: invite)
  end

  def edit(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    changeset = Invites.change_invite(invite)
    render(conn, "edit.html", invite: invite, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invite" => invite_params}) do
    invite = Invites.get_invite!(id)

    case Invites.update_invite(invite, invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite updated successfully.")
        |> redirect(to: Routes.invite_path(conn, :show, invite))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invite: invite, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    {:ok, _invite} = Invites.delete_invite(invite)

    conn
    |> put_flash(:info, "Invite deleted successfully.")
    |> redirect(to: Routes.invite_path(conn, :index))
  end
end
