defmodule Support.Factories do
  alias AdjustedTabular.Storage

  def setup_test_db() do
    drop_test_db()

    with {:ok, pid, _} <- Storage.Database.set_up_table(table: "test", db: "foo") do
      :ok =
        Enum.each(
          1..5,
          fn i -> Storage.Query.insert_row(pid, "test", i, rem(i, 3), rem(i, 5)) end
        )
    else
      e ->
        require Logger
        Logger.error(inspect(e))
    end
  end

  defp drop_test_db() do
    {:ok, pid} = Storage.Database.connect("foo")
    s = "DROP TABLE IF EXISTS test;"

    Postgrex.query!(pid, s, [])
  end
end
