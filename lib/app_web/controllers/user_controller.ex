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
          namespace  = "user auth"
          max_age    =  180 * 24 * 60 * 60 # 6 Ay

          old_refresh_token = get_session(conn, :refresh_token)

          if old_refresh_token do
            refresh_token_verify(conn, namespace, old_refresh_token)
          else
            new_refresh_token(conn, namespace, user_id, max_age)
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

      namespace  = "user auth"
      refresh_token = params["refresh_token"]

      old_access_token = get_session(conn, :access_token)
      if old_access_token do
        access_token_verify(conn, old_access_token)
      else
        new_access_token(conn, namespace, refresh_token)
      end

    end
  end

  defp refresh_token_verify(conn, namespace, token ) do
    # 6 Aylık Refresh Token Süresini kontrol eder.
    case Phoenix.Token.verify(conn, namespace, token ) do
      {:ok, _} ->
        conn
          |> put_status(:ok)
          |> put_view(MainModuleWeb.UserView)
          |> render("refresh_token.json", token: token)
      {:error, _} ->
        conn
          |> delete_session(:refresh_token)
          |> put_status(:unauthorized)
          |> put_view(MainModuleWeb.ErrorView)
          |> render("401.json", message: "Unauthenticated user")
    end
  end

  defp new_refresh_token(conn, namespace, user_id, max_age ) do
    token = Phoenix.Token.sign(conn, namespace, user_id, max_age: max_age) 
    conn
      |> put_session(:refresh_token, token)
      |> put_status(:ok)
      |> put_view(MainModuleWeb.UserView)
      |> render("refresh_token.json", token: token)
  end

  defp new_access_token(conn, namespace, token ) do
    case Phoenix.Token.verify(conn, namespace, token ) do
      {:ok, user_id} ->
        token = MainModule.Token.generate_and_sign!(%{"user_id" => user_id})
        conn
          |> put_session(:access_token, token)
          |> put_status(:ok)
          |> put_view(MainModuleWeb.UserView)
          |> render("access_token.json", token: token)
      {:error, _} ->
        conn
          |> put_status(:unauthorized)
          |> put_view(MainModuleWeb.ErrorView)
          |> render("debug.json", message: "Unauthenticated user")
    end
  end

  defp access_token_verify(conn, token) do
    # 15 Dakikalık Access Token Süresini kontrol eder.
    case MainModule.Token.verify_and_validate(token) do
      {:ok, _claim_map} ->
        conn
          |> put_status(:ok)
          |> put_view(MainModuleWeb.UserView)
          |> render("access_token.json", token: token)
      {:error, _} ->
        conn
          |> delete_session(:access_token)
          |> put_status(:unauthorized)
          |> put_view(MainModuleWeb.ErrorView)
          |> render("401.json", message: "Unauthenticated user")
    end
  end

end