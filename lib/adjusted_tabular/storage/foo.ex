defmodule AdjustedTabular.Storage.Foo do
  alias AdjustedTabular.Storage.Database, as: DB
  alias AdjustedTabular.Storage.Query
  require Logger

  @interval 1..1_000_000
  @chunk_size Keyword.get(
                Application.get_env(:postgrex, :database_connection),
                :pool_size
              )

  def seed do
    {:ok, pid, _} = create_table()

    query =
      Postgrex.prepare!(
        pid,
        "",
        Query.compose_insert_rows(@chunk_size)
      )

    Stream.zip([@interval, Stream.cycle([1, 2, 0]), Stream.cycle([1, 2, 3, 4, 0])])
    |> Stream.map(&Tuple.to_list(&1))
    |> Stream.chunk_every(@chunk_size)
    |> Task.async_stream(&process_chunk(&1, pid, query))
    |> Stream.run()
  end

  defp process_chunk(chunk, pid, query) do
    run_query_in_transaction(pid, query, List.flatten(chunk))
  end

  defp run_query_in_transaction(pid, query, values) do
    pid
    |> Postgrex.transaction(fn conn -> Postgrex.execute(pid, query, values) end)
  end

  defp create_table() do
    {:ok, pid, _} =
      DB.set_up_table(
        table: "source",
        db: "foo"
      )
  end
end
