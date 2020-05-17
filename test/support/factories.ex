defmodule Support.Factories do
  alias AdjustedTabular.Storage.{Database, Query}

  def setup_test_table(db_pid, rows_count \\ 5) do
    drop_table(db_pid, "test")

    with {:ok, pid, _} <- Database.set_up_table(table: "test", pid: db_pid) do
      insert_query_values =
        1..rows_count
        |> Enum.map(fn n -> [n, rem(n, 3), rem(n, 5)] end)
        |> List.flatten()

      Query.compose_insert_rows(rows_count, "test")
      |> (&Postgrex.prepare!(pid, "", &1)).()
      |> (&Postgrex.execute(pid, &1, insert_query_values)).()

      {:ok, pid}
    else
      e ->
        require Logger
        Logger.error(inspect(e))
    end
  end

  def drop_table(db_pid, name) do
    Postgrex.query!(
      db_pid,
      "DROP TABLE IF EXISTS #{name};",
      []
    )
  end
end
