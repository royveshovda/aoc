defmodule Y2019.D18Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 18, async: true do
    test "part 1 with input" do
      assert Y2019.D18.p1(input_string()) == 3832
    end

    test "part 2 with input" do
      assert Y2019.D18.p2(input_string()) == 1724
    end
  end
end
