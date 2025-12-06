defmodule Y2023.D17Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 17, async: true do
    test "part 1 with input" do
      assert Y2023.D17.p1(input_string()) == 724
    end

    test "part 2 with input" do
      assert Y2023.D17.p2(input_string()) == 877
    end
  end
end
