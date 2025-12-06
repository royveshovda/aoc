defmodule Y2019.D13Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 13, async: true do
    test "part 1 with input" do
      assert Y2019.D13.p1(input_string()) == 193
    end

    test "part 2 with input" do
      assert Y2019.D13.p2(input_string()) == 10547
    end
  end
end
