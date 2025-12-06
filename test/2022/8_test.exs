defmodule Y2022.D8Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 8, async: true do
    test "part 1 with input" do
      assert Y2022.D8.p1(input_string()) == 1843
    end

    test "part 2 with input" do
      assert Y2022.D8.p2(input_string()) == 180000
    end
  end
end
