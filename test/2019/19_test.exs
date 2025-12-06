defmodule Y2019.D19Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 19, async: true do
    test "part 1 with input" do
      assert Y2019.D19.p1(input_string()) == 229
    end

    test "part 2 with input" do
      assert Y2019.D19.p2(input_string()) == 6950903
    end
  end
end
