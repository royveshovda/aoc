import AOC

aoc_test 2017, 15, async: true do
  test "part 1 input" do
    assert Y2017.D15.p1(input_string()) == 609
  end

  test "part 2 input" do
    assert Y2017.D15.p2(input_string()) == 253
  end
end
