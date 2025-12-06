defmodule Y2020.D7Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 7, async: true do
    test "part 1 with input" do
      assert Y2020.D7.p1(input_string()) == 332
    end

    test "part 2 with input" do
      assert Y2020.D7.p2(input_string()) == 10875
    end
  end
end
