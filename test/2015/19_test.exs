import AOC

aoc_test 2015, 19, async: true do
  test "part 1 input" do
    assert Y2015.D19.p1(input_string()) == 535
  end

  test "part 2 input" do
    assert Y2015.D19.p2(input_string()) == 212
  end
end
