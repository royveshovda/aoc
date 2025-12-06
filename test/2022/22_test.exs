defmodule Y2022.D22Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 22, async: true do
    test "part 1 with input" do
      assert Y2022.D22.p1(input_string()) == 159034
    end

    test "part 2 with input" do
      assert Y2022.D22.p2(input_string()) == 147245
    end
  end
end
