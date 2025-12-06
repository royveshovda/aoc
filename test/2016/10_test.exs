import AOC

aoc_test 2016, 10, async: true do
  test "part 1 input" do
    assert Y2016.D10.p1(input_string()) == 27
  end

  test "part 2 input" do
    assert Y2016.D10.p2(input_string()) == 13727
  end
end
