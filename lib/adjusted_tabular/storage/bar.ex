defmodule AdjustedTabular.Storage.Bar do
  alias AdjustedTabular.Storage.Database, as: DB
  alias AdjustedTabular.Storage.Query
  require Logger

  @db_name "bar"

  def seed(table_name) do
    Logger.info("🌱 Seeding table #{table_name} in #{@db_name} database")
    {:ok, bar_pid, _} = connect_or_create_table(table_name)
    {:ok, foo_pid} = DB.connect("foo")

    if Query.table_is_empty?(bar_pid, table_name) do
      Task.async(fn -> copy_source_to_file(foo_pid) end)
      |> Task.await(:infinity)

      Task.async(fn -> copy_dest_from_file(bar_pid) end)
      |> Task.await(:infinity)
    end

    Logger.info("✅ Done...")
  end

  defp copy_source_to_file(pid) do
    Postgrex.transaction(pid, fn conn ->
      Postgrex.stream(conn, "COPY source TO '/tmp/source.csv' DELIMITER ',';", [])
      |> Enum.to_list()
    end)
  end

  defp copy_dest_from_file(pid) do
    Postgrex.transaction(pid, fn conn ->
      Postgrex.stream(conn, "COPY dest FROM '/tmp/source.csv' DELIMITER ',';", [])
      |> Enum.to_list()
    end)
  end

  defp connect_or_create_table(table_name) do
    {:ok, pid, _} =
      DB.set_up_table(
        table: table_name,
        db: @db_name
      )
  end
end
