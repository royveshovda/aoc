defmodule Y2022.D6Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 6, async: true do
    test "part 1 with input" do
      assert Y2022.D6.p1(input_string()) == 1361
    end

    test "part 2 with input" do
      assert Y2022.D6.p2(input_string()) == 3263
    end
  end
end
