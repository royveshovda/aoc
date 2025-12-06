import AOC

aoc_test 2017, 14, async: true do
  test "part 1 input" do
    assert Y2017.D14.p1(input_string()) == 8250
  end

  test "part 2 input" do
    assert Y2017.D14.p2(input_string()) == 1113
  end
end
