defmodule UserStoriesWeb.EventController do
  use UserStoriesWeb, :controller

  alias UserStories.Events
  alias UserStories.Events.Event
  alias UserStories.Comments
  alias UserStories.Invites
  alias UserStoriesWeb.Plugs

  plug Plugs.RequireUser when action not in [:index, :show]
  plug :fetch_event when action in [:show, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    events = Events.list_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    event_params = event_params
    |> Map.put("user_id", conn.assigns[:current_user].id)

    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end

  def require_owner(conn, _args) do
   user = conn.assigns[:current_user]
   event = conn.assigns[:event]

   if user.id == event.user_id do
     conn
   else
     conn
     |> put_flash(:error, "You don't have access to that.")
     |> redirect(to: Routes.page_path(conn, :index))
     |> halt()
   end
 end

  def show(conn, %{"id" => _id}) do
    ev = Events.load_comments(conn.assigns[:event])
    event = Events.load_invites(ev)
    comm = %Comments.Comment{
      event_id: event.id,
      user_id: current_user_id(conn)
    }
    inv = %Invites.Invite{
      event_id: event.id,
      response: :Pending
    }
    curr = Invites.get_invite_by_event_and_user(event.id, current_user_id(conn))
    current_change = if curr do
      Invites.change_invite(curr)
    else
      Invites.change_invite(inv)
    end
    new_invite = Invites.change_invite(inv)
    new_comment = Comments.change_comment(comm)
    render(conn, "show.html", event: event, new_comment: new_comment, new_invite: new_invite, current_change: current_change, current_invite: curr)
  end

  def edit(conn, %{"id" => _id}) do
    event = conn.assigns[:event]
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "event" => event_params}) do
    event = conn.assigns[:event]

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    event = conn.assigns[:event]
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
