defmodule AdjustedTabular.HttpRouterTest do
  use ExUnit.Case

  @base_url "http://localhost:4000"

  setup do
    setup_test_db

    HTTPoison.start()
    :ok
  end

  describe "get /is_alive" do
    test "returns OK" do
      {:ok, response} = HTTPoison.get("#{@base_url}/is_alive")

      assert response.status_code == 200
      assert response.body == "ok"
    end
  end

  describe "get /dbs/:db_name/tables/:table_name" do
    test "when db and table exist, the response is chunked" do
      url = "#{@base_url}/dbs/foo/tables/test"
      %HTTPoison.AsyncResponse{id: id} = HTTPoison.get!(url, %{}, stream_to: self())

      assert_receive %HTTPoison.AsyncStatus{id: ^id, code: 200}, 1_000
      assert_receive %HTTPoison.AsyncHeaders{id: ^id, headers: headers}, 1_000
      assert_receive %HTTPoison.AsyncChunk{id: ^id, chunk: _chunk}, 1_000
      assert_receive %HTTPoison.AsyncEnd{id: ^id}, 1_000
      assert is_list(headers)
    end

    test "when db and table exist, the response header includes csv header" do
      url = "#{@base_url}/dbs/foo/tables/test"
      %HTTPoison.AsyncResponse{id: id} = HTTPoison.get!(url, %{}, stream_to: self())

      assert_receive %HTTPoison.AsyncHeaders{id: ^id, headers: h}, 1_000

      headers = Enum.into(h, %{})
      assert headers["content-type"] =~ "application/csv"
    end
  end

  defp drop_test_db() do
    {:ok, pid} = AdjustedTabular.Database.connect("foo")
    s = "DROP TABLE IF EXISTS test;"

    Postgrex.query!(pid, s, [])
  end

  defp setup_test_db() do
    alias AdjustedTabular.Workers.Table

    drop_test_db()

    columns_definition = "a integer, b integer, c integer"

    with {:ok, pid, _} <- Table.create(table: "test", db: "foo", columns: columns_definition) do
      :ok =
        Enum.each(
          1..1000,
          fn i -> Table.insert_row(pid, "test", i + 17, i + 19, i + 23) end
        )
    else
      e ->
        require Logger
        Logger.error(inspect(e))
    end
  end
end
