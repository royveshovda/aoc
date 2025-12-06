defmodule Y2023.D21Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2023, 21, async: true do
    @tag :skip
    @tag :slow
    test "part 1 with input" do
      # Takes > 3 minutes - algorithm needs optimization
      assert Y2023.D21.p1(input_string()) == 3795
    end

    @tag :skip
    @tag :slow
    test "part 2 with input" do
      # Takes > 3 minutes - algorithm needs optimization
      assert Y2023.D21.p2(input_string()) == 630129824772393
    end
  end
end
