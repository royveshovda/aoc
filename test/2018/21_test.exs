import AOC

aoc_test 2018, 21, async: true do
  test "part 1 input" do
    assert Y2018.D21.p1(input_string()) == 13_522_479
  end

  test "part 2 input" do
    assert Y2018.D21.p2(input_string()) == 14_626_276
  end
end
