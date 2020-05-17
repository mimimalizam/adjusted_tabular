defmodule AdjustedTabular.Storage.BarTest do
  use ExUnit.Case

  alias AdjustedTabular.Storage.Query, as: Q

  describe "seed_if_empty" do
    test "when there are few rows in the table, it doesn't add new rows" do
      {:ok, pid} = Support.Factories.setup_test_table("bar", 2)

      AdjustedTabular.Storage.Bar.seed_if_empty(pid, "test", "bar")

      assert Q.row_count(pid, "test") == {pid, 2}
    end
  end
end
