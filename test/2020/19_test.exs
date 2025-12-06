defmodule Y2020.D19Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 19, async: true do
    test "part 1 with input" do
      assert Y2020.D19.p1(input_string()) == 222
    end

    test "part 2 with input" do
      assert Y2020.D19.p2(input_string()) == 339
    end
  end
end
