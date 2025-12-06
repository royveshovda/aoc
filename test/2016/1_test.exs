import AOC

aoc_test 2016, 1, async: true do
  test "part 1 input" do
    assert Y2016.D1.p1(input_string()) == 288
  end

  test "part 2 input" do
    assert Y2016.D1.p2(input_string()) == 111
  end
end
