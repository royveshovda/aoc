defmodule Y2025.D4Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2025, 4, async: true do
    test "part 1 with input" do
      assert Y2025.D4.p1(input_string()) == 1491
    end

    test "part 2 with input" do
      assert Y2025.D4.p2(input_string()) == 8722
    end
  end
end
