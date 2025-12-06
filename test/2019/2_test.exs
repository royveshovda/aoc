defmodule Y2019.D2Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 2, async: true do
    test "part 1 with input" do
      assert Y2019.D2.p1(input_string()) == 4570637
    end

    test "part 2 with input" do
      assert Y2019.D2.p2(input_string()) == 5485
    end
  end
end
