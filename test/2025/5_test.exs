defmodule Y2025.D5Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2025, 5, async: true do
    test "part 1 with input" do
      assert Y2025.D5.p1(input_string()) == 509
    end

    test "part 2 with input" do
      assert Y2025.D5.p2(input_string()) == 336790092076620
    end
  end
end
