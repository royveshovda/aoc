defmodule Y2020.D8Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 8, async: true do
    test "part 1 with input" do
      assert Y2020.D8.p1(input_string()) == 1584
    end

    test "part 2 with input" do
      assert Y2020.D8.p2(input_string()) == 920
    end
  end
end
