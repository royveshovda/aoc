defmodule Y2022.D21Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2022, 21, async: true do
    test "part 1 with input" do
      assert Y2022.D21.p1(input_string()) == 21120928600114
    end

    test "part 2 with input" do
      assert Y2022.D21.p2(input_string()) == 3453748220116
    end
  end
end
