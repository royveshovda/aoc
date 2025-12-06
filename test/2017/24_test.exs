import AOC

aoc_test 2017, 24, async: true do
  test "part 1 input" do
    assert Y2017.D24.p1(input_string()) == 1859
  end

  test "part 2 input" do
    assert Y2017.D24.p2(input_string()) == 1799
  end
end
