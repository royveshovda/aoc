import AOC

aoc_test 2015, 8, async: true do
  test "part 1 input" do
    assert Y2015.D8.p1(input_string()) == 1333
  end

  test "part 2 input" do
    assert Y2015.D8.p2(input_string()) == 2046
  end
end
