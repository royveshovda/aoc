defmodule Y2019.D21Test do
  use ExUnit.Case, async: true
  import AOC

  aoc_test 2019, 21, async: true do
    test "part 1 with input" do
      assert Y2019.D21.p1(input_string()) == 19355364
    end

    test "part 2 with input" do
      assert Y2019.D21.p2(input_string()) == 1142530574
    end
  end
end
