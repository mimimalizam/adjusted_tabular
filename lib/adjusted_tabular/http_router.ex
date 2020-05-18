defmodule AdjustedTabular.HttpRouter do
  use Plug.Router
  require Logger

  alias AdjustedTabular.Storage.Query
  alias AdjustedTabular.Storage.Database, as: DB

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

  get "/dbs/:db_name/tables/:table_name" do
    with {pid, query} <- Query.compose_db_to_csv_query(db_name, table_name),
         true <- DB.table_exists?(pid, table_name) do
      updated_conn =
        conn
        |> Plug.Conn.put_resp_content_type("application/csv")
        |> send_chunked(200)

      {:ok, _result} =
        Postgrex.transaction(pid, fn conn ->
          Postgrex.stream(conn, query, [])
          |> Stream.map(fn %Postgrex.Result{rows: rows} -> rows end)
          |> merge_stream_chunk
          |> Stream.map(&chunk(updated_conn, &1))
          |> Enum.to_list()
        end)

      updated_conn
    else
      :database_not_found ->
        conn
        |> Plug.Conn.put_resp_content_type("application/csv")
        |> send_chunked(404)

      false ->
        conn
        |> Plug.Conn.put_resp_content_type("application/csv")
        |> send_chunked(404)
    end
  end

  match _ do
    conn
    |> send_resp(404, "Not found")
  end

  defp merge_stream_chunk(stream) do
    stream
    |> Stream.map(fn rows -> Enum.join(rows, "") end)
  end
end
