import AOC

aoc_test 2016, 14, async: true do
  test "part 1 input" do
    assert Y2016.D14.p1(input_string()) == 35186
  end

  test "part 2 input" do
    assert Y2016.D14.p2(input_string()) == 22429
  end
end
