defmodule Y2019.D4Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 4, async: true do
    test "part 1 with input" do
      assert Y2019.D4.p1(input_string()) == 931
    end

    test "part 2 with input" do
      assert Y2019.D4.p2(input_string()) == 609
    end
  end
end
