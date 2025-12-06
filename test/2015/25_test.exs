import AOC

aoc_test 2015, 25, async: true do
  test "part 1 input" do
    assert Y2015.D25.p1(input_string()) == 9_132_360
  end
end
