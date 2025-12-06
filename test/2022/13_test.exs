defmodule Y2022.D13Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 13, async: true do
    test "part 1 with input" do
      assert Y2022.D13.p1(input_string()) == 6046
    end

    test "part 2 with input" do
      assert Y2022.D13.p2(input_string()) == 21423
    end
  end
end
