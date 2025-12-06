defmodule Y2019.D20Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 20, async: true do
    test "part 1 with input" do
      assert Y2019.D20.p1(input_string()) == 496
    end

    test "part 2 with input" do
      assert Y2019.D20.p2(input_string()) == 5886
    end
  end
end
