defmodule AdjustedTabular.Storage.Bar do
  alias AdjustedTabular.Storage.Database, as: DB
  alias AdjustedTabular.Storage.Query
  require Logger

  @table_name "dest"
  @db_name "bar"

  def seed do
    {:ok, bar_pid, _} = create_table()
    {:ok, foo_pid} = DB.connect("foo")

    Task.async(fn -> copy_source_to_file(foo_pid) end)
    |> Task.await(:infinity)

    Task.async(fn -> copy_dest_from_file(bar_pid) end)
    |> Task.await(:infinity)
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

  defp create_table() do
    {:ok, pid, _} =
      DB.set_up_table(
        table: @table_name,
        db: @db_name
      )
  end
end
