defmodule Y2019.D15Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 15, async: true do
    test "part 1 with input" do
      assert Y2019.D15.p1(input_string()) == 234
    end

    test "part 2 with input" do
      assert Y2019.D15.p2(input_string()) == 292
    end
  end
end
