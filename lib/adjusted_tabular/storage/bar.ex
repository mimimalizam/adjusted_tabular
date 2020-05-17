defmodule AdjustedTabular.Storage.Bar do
  alias AdjustedTabular.Storage.Database, as: DB
  alias AdjustedTabular.Storage.Query
  require Logger

  @db_name "bar"

  def seed(table_name) do
    Logger.info("🌱 Inspecting table #{table_name} in #{@db_name} database")
    {:ok, bar_pid, _} = connect_or_create_table(table_name)

    seed_if_empty(table_name, @db_name)

    Logger.info("✅ Done...")
  end

  def seed_if_empty(table_name, db_name) do
    if Query.table_is_empty?(:bar_pid, table_name) do
      Logger.info("🌱 Seeding table #{table_name} in #{db_name} database")

      Task.async(fn -> copy_source_to_file(:foo_pid) end)
      |> Task.await(:infinity)

      Task.async(fn -> copy_dest_from_file(:bar_pid) end)
      |> Task.await(:infinity)
    end
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
        pid: :bar_pid
      )
  end
end
