defmodule Y2019.D6Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 6, async: true do
    test "part 1 with input" do
      assert Y2019.D6.p1(input_string()) == 254447
    end

    test "part 2 with input" do
      assert Y2019.D6.p2(input_string()) == 445
    end
  end
end
