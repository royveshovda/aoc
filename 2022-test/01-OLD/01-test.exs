defmodule Day01Test do
  use ExUnit.Case

  test "day 01 - part 1 - example" do
    input =
      """
      1000
      2000
      3000

      4000

      5000
      6000

      7000
      8000
      9000

      10000
      """
    assert Day01.part1(input) == 24000
  end
end
