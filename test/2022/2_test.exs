defmodule Y2022.D2Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 2, async: true do
    test "part 1 with input" do
      assert Y2022.D2.p1(input_string()) == 10718
    end

    test "part 2 with input" do
      assert Y2022.D2.p2(input_string()) == 14652
    end
  end
end
