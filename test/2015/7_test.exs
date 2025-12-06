import AOC

aoc_test 2015, 7, async: true do
  test "part 1 input" do
    assert Y2015.D7.p1(input_string()) == 956
  end

  test "part 2 input" do
    assert Y2015.D7.p2(input_string()) == 40149
  end
end
