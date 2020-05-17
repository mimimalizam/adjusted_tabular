defmodule AdjustedTabular.Storage.Bar do
  alias AdjustedTabular.Storage.Database, as: DB
  alias AdjustedTabular.Storage.Query
  require Logger

  @db_name "bar"
  @pid :bar_pid

  def seed(table_name) do
    Logger.info("🌱 Inspecting table #{table_name} in #{@db_name} database")

    ensure_table_exists(table_name)

    seed_if_empty(table_name)

    Logger.info("✅ Done...")
  end

  def seed_if_empty(table_name) do
    if Query.table_is_empty?(@pid, table_name) do
      Logger.info("🌱 Seeding table #{table_name} in #{@db_name} database")

      copy_source_to_file(:foo_pid)

      copy_dest_from_file(@pid)
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

  defp ensure_table_exists(table_name) do
    {:ok, pid, _} =
      DB.set_up_table(
        table: table_name,
        pid: @pid
      )
  end
end
