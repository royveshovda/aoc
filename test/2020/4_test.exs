defmodule Y2020.D4Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 4, async: true do
    test "part 1 with input" do
      assert Y2020.D4.p1(input_string()) == 235
    end

    test "part 2 with input" do
      assert Y2020.D4.p2(input_string()) == 194
    end
  end
end
