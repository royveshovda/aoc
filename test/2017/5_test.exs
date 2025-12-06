import AOC

aoc_test 2017, 5, async: true do
  test "part 1 input" do
    assert Y2017.D5.p1(input_string()) == 315_613
  end

  test "part 2 input" do
    assert Y2017.D5.p2(input_string()) == 22_570_529
  end
end
