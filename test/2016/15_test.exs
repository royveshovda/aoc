import AOC

aoc_test 2016, 15, async: true do
  test "part 1 input" do
    assert Y2016.D15.p1(input_string()) == 148_737
  end

  test "part 2 input" do
    assert Y2016.D15.p2(input_string()) == 2_353_212
  end
end
