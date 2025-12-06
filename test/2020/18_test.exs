defmodule Y2020.D18Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2020, 18, async: true do
    test "part 1 with input" do
      assert Y2020.D18.p1(input_string()) == 1451467526514
    end

    test "part 2 with input" do
      assert Y2020.D18.p2(input_string()) == 224973686321527
    end
  end
end
