import AOC

aoc_test 2015, 10, async: true do
  test "part 1 input" do
    assert Y2015.D10.p1(input_string()) == 360_154
  end

  @tag timeout: :infinity
  test "part 2 input" do
    assert Y2015.D10.p2(input_string()) == 5_103_798
  end
end
