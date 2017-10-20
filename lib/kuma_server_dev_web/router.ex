defmodule KumaServerDevWeb.Router do
  use KumaServerDevWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KumaServerDevWeb do
    pipe_through :api # Use the default browser stack

    post "/", PageController, :index
  end
end
