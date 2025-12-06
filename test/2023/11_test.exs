defmodule Y2023.D11Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 11, async: true do
    test "part 1 with input" do
      assert Y2023.D11.p1(input_string()) == 9795148
    end

    test "part 2 with input" do
      assert Y2023.D11.p2(input_string()) == 650672493820
    end
  end
end
