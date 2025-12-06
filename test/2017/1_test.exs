import AOC

aoc_test 2017, 1, async: true do
  test "part 1 input" do
    assert Y2017.D1.p1(input_string()) == 1089
  end

  test "part 2 input" do
    assert Y2017.D1.p2(input_string()) == 1156
  end
end
