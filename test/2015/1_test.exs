import AOC

aoc_test 2015, 1, async: true do
  test "part 1 input" do
    assert Y2015.D1.p1(input_string()) == 232
  end

  test "part 2 input" do
    assert Y2015.D1.p2(input_string()) == 1783
  end
end
