defmodule UserStoriesWeb.UserController do
  use UserStoriesWeb, :controller

  alias UserStories.Photos
  alias UserStories.Users
  alias UserStories.Users.User

  plug :fetch_user when action in [:show, :edit, :update, :delete, :photo]
  plug :require_editing_rights when action in [:edit, :update, :delete]

  def fetch_user(conn, _args) do
    id = conn.params["id"]
    user = Users.get_user!(id)
    assign(conn, :user, user)
  end

 def require_editing_rights(conn, _args) do
  user = conn.assigns[:user]

  if current_user_is?(conn, user.id) || user.name == "---CHANGE THIS TO YOUR NAME---" do
    conn
  else
    conn
    |> put_flash(:error, "You don't have access to that.")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end
end

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    up = user_params["photo"]
    user_params = if up do
      {:ok, hash} = Photos.save_photo(up.filename, up.path)
      Map.put(user_params, "photo_hash", hash)
    else
      hash = Photos.get_default()
      Map.put(user_params, "photo_hash", hash)
    end

    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    user = conn.assigns[:user]
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => _id}) do
    user = conn.assigns[:user]
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "user" => user_params}) do
    user = conn.assigns[:user]
    up = user_params["photo"]

    user_params = if up do
      # FIXME: Remove old image
      {:ok, hash} = Photos.save_photo(up.filename, up.path)
      Map.put(user_params, "photo_hash", hash)
    else
      user_params
    end

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def photo(conn, %{"id" => _id}) do
   user = conn.assigns[:user]

   {:ok, _name, data} = Photos.load_photo(user.photo_hash)
   conn
   |> put_resp_content_type("image/jpeg")
   |> send_resp(200, data)
 end

  def delete(conn, %{"id" => _id}) do
    user = conn.assigns[:user]
    {:ok, _user} = Users.delete_user(user)
    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
