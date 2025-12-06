import AOC

aoc_test 2015, 21, async: true do
  test "part 1 input" do
    assert Y2015.D21.p1(input_string()) == 78
  end

  test "part 2 input" do
    assert Y2015.D21.p2(input_string()) == 148
  end
end
