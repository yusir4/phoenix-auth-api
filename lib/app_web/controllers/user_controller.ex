defmodule MainModuleWeb.UserController do
  use MainModuleWeb, :controller

  alias MainModule.Account
  alias MainModule.Account.User

  action_fallback MainModuleWeb.FallbackController

  def index(conn, _params) do
    users = Account.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Account.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Account.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Account.get_user!(id)

    with {:ok, %User{} = user} <- Account.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Account.get_user!(id)

    with {:ok, %User{}} <- Account.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, params) do
    if params["refresh_token"] == nil and params["email"] != nil and params["password"] != nil do
    # Email ve Şifre parametresi geldi
      email = params["email"]
      password = params["password"]
      case MainModule.Account.authenticate_user(email, password) do
        {:ok, user} ->
          # Kullanıcı adı ve şifresi doğru.
          # Eski Refresh Token varsa onu kullan yoksa Yeni oluştur.

          user_id    = user.id
          secret     = "secret"
          namespace  = "user auth"
          max_age    =  180 * 24 * 60 * 60 # 6 Ay

          old_refresh_token = get_session(conn, :refresh_token)

          if old_refresh_token do
            conn
            |> put_status(:ok)
            |> put_view(MainModuleWeb.UserView)
            |> render("refresh_token.json", token: old_refresh_token)
          else
            token = Phoenix.Token.sign(secret, namespace, user_id, max_age: max_age) 
            conn
              |> put_session(:refresh_token, token)
              |> put_status(:ok)
              |> put_view(MainModuleWeb.UserView)
              |> render("refresh_token.json", token: token)
            end
        {:error, message} ->
          # Kullanıcı adı ve şifresi yanlış.
          conn
            |> delete_session(:current_user_id)
            |> put_status(:unauthorized)
            |> put_view(MainModuleWeb.ErrorView)
            |> render("401.json", message: message)
      end
    end
    if params["refresh_token"] != nil and params["email"] == nil and params["password"] == nil do
    # Refresh Token parametresi geldi
    # Eski Access Token varsa onu kullan yoksa Yeni oluştur.
      old_access_token = get_session(conn, :access_token)
      if old_access_token do
        conn
          |> put_status(:ok)
          |> render("access_token.json", token: old_access_token)
      else
        extra_claims = %{"type" => :access_token}
        token = MainModule.Token.generate_and_sign!(extra_claims)
        conn
          |> put_session(:access_token, token)
          |> put_status(:ok)
          |> render("access_token.json", token: token)
      end
    end
  end
end