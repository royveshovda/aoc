defmodule Y2020.D25Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 25, async: true do
    test "part 1 with input" do
      assert Y2020.D25.p1(input_string()) == 16311885
    end
  end
end
