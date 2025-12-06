defmodule Y2023.D1Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 1, async: true do
    test "part 1 with input" do
      assert Y2023.D1.p1(input_string()) == 54968
    end

    test "part 2 with input" do
      assert Y2023.D1.p2(input_string()) == 54094
    end
  end
end
