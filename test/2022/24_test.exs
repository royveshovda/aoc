defmodule Y2022.D24Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 24, async: true do
    test "part 1 with input" do
      assert Y2022.D24.p1(input_string()) == 343
    end

    test "part 2 with input" do
      assert Y2022.D24.p2(input_string()) == 960
    end
  end
end
