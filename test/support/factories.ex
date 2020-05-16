defmodule Support.Factories do
  alias AdjustedTabular.Storage

  def setup_test_table(db_name, rows_count \\ 5) do
    drop_test_db(db_name)

    with {:ok, pid, _} <- Storage.Database.set_up_table(table: "test", db: db_name) do
      Enum.each(
        1..rows_count,
        fn i -> Storage.Query.insert_row(pid, "test", i, rem(i, 3), rem(i, 5)) end
      )

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
