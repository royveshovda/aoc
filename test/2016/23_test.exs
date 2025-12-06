import AOC

aoc_test 2016, 23, async: true do
  test "part 1 input" do
    assert Y2016.D23.p1(input_string()) == 12654
  end

  test "part 2 input" do
    assert Y2016.D23.p2(input_string()) == 479_009_214
  end
end
