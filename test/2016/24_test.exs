import AOC

aoc_test 2016, 24, async: true do
  test "part 1 input" do
    assert Y2016.D24.p1(input_string()) == 430
  end

  test "part 2 input" do
    assert Y2016.D24.p2(input_string()) == 700
  end
end
