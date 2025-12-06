import AOC

aoc_test 2016, 13, async: true do
  test "part 1 input" do
    assert Y2016.D13.p1(input_string()) == 86
  end

  test "part 2 input" do
    assert Y2016.D13.p2(input_string()) == 127
  end
end
