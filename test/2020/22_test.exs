defmodule Y2020.D22Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 22, async: true do
    test "part 1 with input" do
      assert Y2020.D22.p1(input_string()) == 33400
    end

    test "part 2 with input" do
      assert Y2020.D22.p2(input_string()) == 33745
    end
  end
end
