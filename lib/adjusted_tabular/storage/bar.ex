defmodule AdjustedTabular.Storage.Bar do
  alias AdjustedTabular.Storage.Database, as: DB
  alias AdjustedTabular.Storage.Query
  require Logger

  @table_name "dest"
  @db_name "bar"

  def seed do
    {:ok, pid, _} = create_table()
  end

  defp create_table() do
    {:ok, pid, _} =
      DB.set_up_table(
        table: @table_name,
        db: @db_name
      )
  end
end
