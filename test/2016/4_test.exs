import AOC

aoc_test 2016, 4, async: true do
  test "part 1 input" do
    assert Y2016.D4.p1(input_string()) == 245_102
  end

  test "part 2 input" do
    assert Y2016.D4.p2(input_string()) == 324
  end
end
