import AOC

aoc_test 2015, 13, async: true do
  test "part 1 input" do
    assert Y2015.D13.p1(input_string()) == 709
  end

  test "part 2 input" do
    assert Y2015.D13.p2(input_string()) == 668
  end
end
