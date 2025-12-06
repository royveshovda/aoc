defmodule Y2023.D10Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 10, async: true do
    test "part 1 with input" do
      assert Y2023.D10.p1(input_string()) == 6875
    end

    test "part 2 with input" do
      assert Y2023.D10.p2(input_string()) == 471
    end
  end
end
