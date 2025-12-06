defmodule Y2019.D5Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 5, async: true do
    test "part 1 with input" do
      assert Y2019.D5.p1(input_string()) == 15314507
    end

    test "part 2 with input" do
      assert Y2019.D5.p2(input_string()) == 652726
    end
  end
end
