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

  get "/chunked" do
    updated_conn =
      conn
      |> Plug.Conn.put_resp_content_type("application/csv")
      |> send_chunked(200)

    chunk(updated_conn, "Lorem ipsum dolor sit amet, consectetur adipisicin, ")
    chunk(updated_conn, "sed do eiusmod tempor incididunt ut labore et dolore")
    chunk(updated_conn, "sunt in culpa qui officia deserunt mollit anim id es")

    updated_conn
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end
end
