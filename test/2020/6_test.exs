defmodule Y2020.D6Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 6, async: true do
    test "part 1 with input" do
      assert Y2020.D6.p1(input_string()) == 7283
    end

    test "part 2 with input" do
      assert Y2020.D6.p2(input_string()) == 3520
    end
  end
end
