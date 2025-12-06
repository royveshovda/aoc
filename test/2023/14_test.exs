defmodule Y2023.D14Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 14, async: true do
    test "part 1 with input" do
      assert Y2023.D14.p1(input_string()) == 102497
    end

    test "part 2 with input" do
      assert Y2023.D14.p2(input_string()) == 105008
    end
  end
end
