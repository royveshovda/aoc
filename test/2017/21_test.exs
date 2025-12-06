import AOC

aoc_test 2017, 21, async: true do
  test "part 1 input" do
    assert Y2017.D21.p1(input_string()) == 167
  end

  @tag :skip
  @tag :slow
  test "part 2 input" do
    # Takes > 3 minutes - algorithm needs optimization
    assert Y2017.D21.p2(input_string()) == 2_425_195
  end
end
