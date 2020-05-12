defmodule AdjustedTabular.HttpRouter do
  use Plug.Router
  require Logger

  plug(:match)
  plug(:dispatch)

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link([]) do
    Logger.info("Running router in #{Mix.env()} environment")
    {:ok, _} = Plug.Adapters.Cowboy.http(AdjustedTabular.HttpRouter, [], port: 4000)
  end

  get "/is_alive" do
    send_resp(conn, 200, "ok")
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end
end
