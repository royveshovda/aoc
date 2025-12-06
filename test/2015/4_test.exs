import AOC

aoc_test 2015, 4, async: true do
  test "part 1 input" do
    assert Y2015.D4.p1(input_string()) == 254_575
  end

  test "part 2 input" do
    assert Y2015.D4.p2(input_string()) == 1_038_736
  end
end
