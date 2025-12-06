defmodule Y2025.D6Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2025, 6, async: true do
    test "part 1 with input" do
      assert Y2025.D6.p1(input_string()) == 6343365546996
    end

    test "part 2 with input" do
      assert Y2025.D6.p2(input_string()) == 11136895955912
    end
  end
end
