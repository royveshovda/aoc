import AOC

aoc_test 2017, 8, async: true do
  test "part 1 input" do
    assert Y2017.D8.p1(input_string()) == 7296
  end

  test "part 2 input" do
    assert Y2017.D8.p2(input_string()) == 8186
  end
end
