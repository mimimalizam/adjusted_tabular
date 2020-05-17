defmodule AdjustedTabular.Storage.Foo do
  alias AdjustedTabular.Storage.Database, as: DB
  alias AdjustedTabular.Storage.Query
  require Logger

  @db_name "foo"
  @pid :foo_pid
  @row_count 1..1_000_000
  @chunk_size Keyword.get(
                Application.get_env(:postgrex, :database_connection),
                :pool_size
              )

  def seed(table_name) do
    Logger.info("🌱 Inspecting table #{table_name} in #{@db_name} database")

    ensure_table_exists(table_name)

    seed_if_empty(table_name, @row_count, @chunk_size)

    Logger.info("✅ Done...")
  end

  def seed_if_empty(table_name, row_count, chunk_size) do
    if Query.table_is_empty?(@pid, table_name) do
      Logger.info("🌱 Seeding table #{table_name} in #{@db_name} database")

      query =
        Postgrex.prepare!(
          @pid,
          "",
          Query.compose_insert_rows(chunk_size, table_name)
        )

      Stream.zip([row_count, Stream.cycle([1, 2, 0]), Stream.cycle([1, 2, 3, 4, 0])])
      |> Stream.map(&Tuple.to_list(&1))
      |> Stream.chunk_every(chunk_size)
      |> Task.async_stream(&process_chunk(&1, query))
      |> Stream.run()
    end
  end

  defp process_chunk(chunk, query) do
    chunk
    |> List.flatten()
    |> run_query_in_transaction(query)
  end

  defp run_query_in_transaction(values, query) do
    Postgrex.transaction(
      @pid,
      fn conn -> Postgrex.execute(@pid, query, values) end
    )
  end

  defp ensure_table_exists(table_name) do
    {:ok, pid, _} =
      DB.set_up_table(
        table: table_name,
        pid: @pid
      )
  end
end
