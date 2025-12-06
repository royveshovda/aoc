defmodule Y2019.D10Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 10, async: true do
    test "part 1 with input" do
      assert Y2019.D10.p1(input_string()) == 247
    end

    test "part 2 with input" do
      assert Y2019.D10.p2(input_string()) == 1919
    end
  end
end
