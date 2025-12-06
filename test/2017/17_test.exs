import AOC

aoc_test 2017, 17, async: true do
  test "part 1 input" do
    assert Y2017.D17.p1(input_string()) == 1506
  end

  test "part 2 input" do
    assert Y2017.D17.p2(input_string()) == 39_479_736
  end
end
