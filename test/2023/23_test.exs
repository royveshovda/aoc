defmodule Y2023.D23Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 23, async: true do
    test "part 1 with input" do
      assert Y2023.D23.p1(input_string()) == 2218
    end

    @tag :skip
    @tag :slow
    test "part 2 with input" do
      # Takes > 2 minutes - algorithm needs optimization
      assert Y2023.D23.p2(input_string()) == 6674
    end
  end
end
