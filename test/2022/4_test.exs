defmodule Y2022.D4Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 4, async: true do
    test "part 1 with input" do
      assert Y2022.D4.p1(input_string()) == 605
    end

    test "part 2 with input" do
      assert Y2022.D4.p2(input_string()) == 914
    end
  end
end
