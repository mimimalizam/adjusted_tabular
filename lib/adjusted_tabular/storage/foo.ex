defmodule AdjustedTabular.Storage.Foo do
  alias AdjustedTabular.Storage.Database, as: DB
  alias AdjustedTabular.Storage.Query
  require Logger

  @db_name "foo"
  @row_count 1..1_000_000
  @chunk_size Keyword.get(
                Application.get_env(:postgrex, :database_connection),
                :pool_size
              )

  def seed(table_name) do
    Logger.info("🌱 Inspecting table #{table_name} in #{@db_name} database")

    {:ok, pid, _} = connect_or_create_table(table_name)

    seed_if_empty(pid, table_name, @db_name, @row_count, @chunk_size)

    Logger.info("✅ Done...")
  end

  def seed_if_empty(pid, table_name, db_name, row_count, chunk_size) do
    if Query.table_is_empty?(pid, table_name) do
      Logger.info("🌱 Seeding table #{table_name} in #{db_name} database")

      query =
        Postgrex.prepare!(
          pid,
          "",
          Query.compose_insert_rows(chunk_size, table_name)
        )

      Stream.zip([row_count, Stream.cycle([1, 2, 0]), Stream.cycle([1, 2, 3, 4, 0])])
      |> Stream.map(&Tuple.to_list(&1))
      |> Stream.chunk_every(chunk_size)
      |> Task.async_stream(&process_chunk(&1, pid, query))
      |> Stream.run()
    end
  end

  defp process_chunk(chunk, pid, query) do
    run_query_in_transaction(pid, query, List.flatten(chunk))
  end

  defp run_query_in_transaction(pid, query, values) do
    pid
    |> Postgrex.transaction(fn conn -> Postgrex.execute(pid, query, values) end)
  end

  defp connect_or_create_table(table_name) do
    {:ok, pid, _} =
      DB.set_up_table(
        table: table_name,
        pid: :foo_pid
      )
  end
end
