import AOC

aoc_test 2016, 7, async: true do
  test "part 1 input" do
    assert Y2016.D7.p1(input_string()) == 105
  end

  test "part 2 input" do
    assert Y2016.D7.p2(input_string()) == 258
  end
end
