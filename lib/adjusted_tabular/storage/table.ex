defmodule AdjustedTabular.Storage.Table do
  alias AdjustedTabular.Storage.Database, as: DB
  require Logger

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
  def create(table: table_name, db: db_name, columns: columns_string) do
    require Logger
    {:ok, pid} = DB.connect(db_name)

    try do
      {
        :ok,
        pid,
        Postgrex.query!(pid, "CREATE TABLE #{table_name}(#{columns_string})", [])
      }
    rescue
      e in Postgrex.Error ->
        case parse_error(e) do
          :table_exists ->
            {:ok, pid, :table_exists}

          :unhandled_error ->
            {:error, e}
        end

      e ->
        Logger.error(inspect(e))
        Kernel.reraise(e, __STACKTRACE__)
    end
  end

  defp parse_error(%Postgrex.Error{postgres: %{code: :duplicate_table}}), do: :table_exists
  defp parse_error(_), do: :unhandled_error

  def insert_row(pid, table, a, b, c) do
    Postgrex.query!(
      pid,
      "INSERT INTO #{table} (a, b, c) values(#{a}, #{b}, #{c})",
      []
    )
  end

  def prepare_db_csv_query(db_name, table_name) do
    {:ok, pid} = AdjustedTabular.Database.connect(db_name)
    s = "COPY (SELECT *FROM #{table_name}) to STDOUT WITH CSV DELIMITER ',';"

    {:ok, query} = Postgrex.prepare(pid, "csv", s)

    {pid, query}
  end
end
