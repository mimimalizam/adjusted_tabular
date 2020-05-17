defmodule Support.Factories do
  alias AdjustedTabular.Storage

  def setup_test_table(db_name, rows_count \\ 5) do
    drop_test_db(db_name)

    with {:ok, pid, _} <- Storage.Database.set_up_table(table: "test", db: db_name) do
      insert_query_values =
        1..rows_count
        |> Enum.map(fn n -> [n, rem(n, 3), rem(n, 5)] end)
        |> List.flatten()

      Storage.Query.compose_insert_rows(rows_count, "test")
      |> (&Postgrex.prepare!(pid, "", &1)).()
      |> (&Postgrex.execute(pid, &1, insert_query_values)).()

      {:ok, pid}
    else
      e ->
        require Logger
        Logger.error(inspect(e))
    end
  end

  defp drop_test_db(db_name) do
    {:ok, pid} = Storage.Database.connect(db_name)
    s = "DROP TABLE IF EXISTS test;"

    Postgrex.query!(pid, s, [])
  end
end
