import AOC

aoc_test 2016, 20, async: true do
  test "part 1 input" do
    assert Y2016.D20.p1(input_string()) == 4_793_564
  end

  test "part 2 input" do
    assert Y2016.D20.p2(input_string()) == 146
  end
end
