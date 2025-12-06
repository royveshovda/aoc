defmodule Y2020.D14Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 14, async: true do
    test "part 1 with input" do
      assert Y2020.D14.p1(input_string()) == 15403588588538
    end

    test "part 2 with input" do
      assert Y2020.D14.p2(input_string()) == 3260587250457
    end
  end
end
