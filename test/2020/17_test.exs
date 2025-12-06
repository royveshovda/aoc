defmodule Y2020.D17Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 17, async: true do
    test "part 1 with input" do
      assert Y2020.D17.p1(input_string()) == 333
    end

    test "part 2 with input" do
      assert Y2020.D17.p2(input_string()) == 2676
    end
  end
end
