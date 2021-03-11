defmodule UserStoriesWeb.CommentController do
  use UserStoriesWeb, :controller

  alias UserStories.Comments
  alias UserStories.Comments.Comment
  alias UserStories.Events

  plug :fetch_comment when action in [:show, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    comments = Comments.list_comments()
    render(conn, "index.html", comments: comments)
  end

  def fetch_comment(conn, _args) do
    id = conn.params["id"]
    comment = Comments.get_comment!(id)
    assign(conn, :comment, comment)
  end

  def require_owner(conn, _args) do
   user = conn.assigns[:current_user]
   comm = conn.assigns[:comment]
   event = Events.get_event!(comm.event_id)

   if user.id == comm.user_id || user.id == event.user_id do
     conn
   else
     conn
     |> put_flash(:error, "You don't have access to that.")
     |> redirect(to: Routes.page_path(conn, :index))
     |> halt()
   end
 end

  def new(conn, _params) do
    changeset = Comments.change_comment(%Comment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"comment" => comment_params}) do
    comment_params = comment_params
    |> Map.put("user_id", current_user_id(conn))
    case Comments.create_comment(comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: Routes.comment_path(conn, :show, comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    comment = conn.assigns[:comment]
    render(conn, "show.html", comment: comment)
  end

  def edit(conn, %{"id" => _id}) do
    comment = conn.assigns[:comment]
    changeset = Comments.change_comment(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "comment" => comment_params}) do
    comment = conn.assigns[:comment]

    case Comments.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: Routes.comment_path(conn, :show, comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    comment = conn.assigns[:comment]
    {:ok, _comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: Routes.comment_path(conn, :index))
  end
end
