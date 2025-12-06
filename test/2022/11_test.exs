defmodule Y2022.D11Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 11, async: true do
    test "part 1 with input" do
      assert Y2022.D11.p1(input_string()) == 54036
    end

    test "part 2 with input" do
      assert Y2022.D11.p2(input_string()) == 13237873355
    end
  end
end
