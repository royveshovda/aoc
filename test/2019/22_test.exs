defmodule Y2019.D22Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 22, async: true do
    test "part 1 with input" do
      assert Y2019.D22.p1(input_string()) == 7096
    end

    test "part 2 with input" do
      assert Y2019.D22.p2(input_string()) == 27697279941366
    end
  end
end
