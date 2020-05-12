defmodule AdjustedTabular.Workers.Table do
  alias AdjustedTabular.Database, as: DB

  def set_up_databases do
    create(
      table: "source",
      db: "foo",
      columns: "a integer, b integer, c integer"
    )

    create(
      table: "dest",
      db: "bar",
      columns: "a integer, b integer, c integer"
    )
  end

  @docs """
  Example columns string definition "a integer, b integer, c integer"
  """
  defp create(table: table_name, db: db_name, columns: columns_string) do
    {:ok, pid} = DB.connect(db_name)

    Postgrex.query!(pid, "CREATE TABLE #{table_name}(#{columns_string})", [])
  end
end
