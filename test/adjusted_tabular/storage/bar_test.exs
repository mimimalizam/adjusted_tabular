defmodule AdjustedTabular.Storage.BarTest do
  use ExUnit.Case

  alias AdjustedTabular.Storage.Query

  describe "seed" do
    test "when there are few rows in the table, it doesn't add new rows" do
      {:ok, pid} = Support.Factories.setup_test_table("bar", 2)

      # simmulate Bar.seed
      query =
        Postgrex.prepare!(
          pid,
          "",
          Query.compose_insert_rows(2, "test")
        )

      AdjustedTabular.Storage.Bar.seed("test")

      # prepare assertion
      q =
        Postgrex.prepare!(
          pid,
          "",
          "SELECT COUNT(*) FROM test;"
        )

      {:ok, q, %Postgrex.Result{rows: [[n]]}} = Postgrex.execute(pid, q, [])

      assert n == 2
    end
  end
end