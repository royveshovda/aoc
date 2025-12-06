defmodule Y2020.D1Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 1, async: true do
    test "part 1 with input" do
      assert Y2020.D1.p1(input_string()) == 982464
    end

    test "part 2 with input" do
      assert Y2020.D1.p2(input_string()) == 162292410
    end
  end
end
