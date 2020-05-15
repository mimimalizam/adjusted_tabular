defmodule AdjustedTabular.Storage.Database do
  @pg_env Application.get_env(:postgrex, :database_connection)

  def connect(db_name) do
    {:ok, pid} = env(database: db_name) |> Postgrex.start_link()
  end

  defp env(params \\ []), do: Keyword.merge(@pg_env, params)
end
