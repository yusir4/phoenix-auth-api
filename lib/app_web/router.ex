defmodule MainModuleWeb.Router do
  use MainModuleWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :api_auth do
    plug :ensure_authenticated
  end

  defp ensure_authenticated(conn, _) do
    request_access_token = get_req_header(conn, "authorization")
    access_token = to_string(request_access_token)
    condition = String.length access_token

    # Header Kısmında Access Token yoksa Unauthenticated döndür.
    if condition != 0 do
      case MainModule.Token.verify_and_validate(access_token) do
        {:ok, _} ->
          conn
        {:error, _} ->
        # Access Token süresi dolmuşsa Unauthenticated döndür.
          conn
            |> put_status(:unauthorized)
            |> put_view(MainModuleWeb.ErrorView)
            |> render("401.json", message: "Unauthenticated user")
            |> halt()
      end
    else
      conn
        |> put_status(:unauthorized)
        |> put_view(MainModuleWeb.ErrorView)
        |> render("401.json", message: "Unauthenticated user")
        |> halt()
    end
  end

  scope "/api", MainModuleWeb do
    pipe_through :api
    post "/users/login", UserController, :sign_in
    post "/users/register", UserController, :create
  end

  scope "/api", MainModuleWeb do
    pipe_through [:api, :api_auth]
    resources "/users", UserController, except: [:new, :edit, :create]
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MainModuleWeb.Telemetry
    end
  end
end
