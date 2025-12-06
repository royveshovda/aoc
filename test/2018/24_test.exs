import AOC

aoc_test 2018, 24, async: true do
  test "part 1 input" do
    assert Y2018.D24.p1(input_string()) == 21070
  end

  test "part 2 input" do
    assert Y2018.D24.p2(input_string()) == 7500
  end
end
