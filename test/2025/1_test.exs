defmodule Y2025.D1Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2025, 1, async: true do
    test "part 1 with input" do
      assert Y2025.D1.p1(input_string()) == 1180
    end

    test "part 2 with input" do
      assert Y2025.D1.p2(input_string()) == 6892
    end
  end
end
