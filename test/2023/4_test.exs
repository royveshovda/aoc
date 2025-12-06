defmodule Y2023.D4Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 4, async: true do
    test "part 1 with input" do
      assert Y2023.D4.p1(input_string()) == 23847
    end

    test "part 2 with input" do
      assert Y2023.D4.p2(input_string()) == 8570000
    end
  end
end
