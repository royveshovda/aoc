defmodule Y2019.D17Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 17, async: true do
    test "part 1 with input" do
      assert Y2019.D17.p1(input_string()) == 3192
    end

    test "part 2 with input" do
      assert Y2019.D17.p2(input_string()) == 684691
    end
  end
end
