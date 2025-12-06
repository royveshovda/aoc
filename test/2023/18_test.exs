defmodule Y2023.D18Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 18, async: true do
    test "part 1 with input" do
      assert Y2023.D18.p1(input_string()) == 56923
    end

    test "part 2 with input" do
      assert Y2023.D18.p2(input_string()) == 66296566363189
    end
  end
end
