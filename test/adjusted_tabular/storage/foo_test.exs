defmodule AdjustedTabular.Storage.FooTest do
  use ExUnit.Case

  alias AdjustedTabular.Storage.Query, as: Q

  describe "seed_if_empty" do
    test "when there are few rows in the table, it doesn't add new rows" do
      Support.Factories.setup_test_table(:foo_pid, 4)

      AdjustedTabular.Storage.Foo.seed_if_empty(:foo_pid, "test", "foo", 4, 2)

      assert Q.row_count(:foo_pid, "test") == {:foo_pid, 4}
    end
  end
end
