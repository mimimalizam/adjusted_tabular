defmodule AdjustedTabular.Storage.BarTest do
  use ExUnit.Case

  alias AdjustedTabular.Storage.Query, as: Q

  describe "seed_if_empty" do
    test "when there are few rows in the table, it doesn't add new rows" do
      Support.Factories.setup_test_table(:bar_pid, 2)

      AdjustedTabular.Storage.Bar.seed_if_empty("test")

      assert Q.row_count(:bar_pid, "test") == {:bar_pid, 2}
    end
  end
end
