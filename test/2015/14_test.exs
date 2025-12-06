import AOC

aoc_test 2015, 14, async: true do
  test "part 1 input" do
    assert Y2015.D14.p1(input_string()) == 2655
  end

  test "part 2 input" do
    assert Y2015.D14.p2(input_string()) == 1059
  end
end
