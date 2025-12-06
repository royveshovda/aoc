import AOC

aoc_test 2015, 5, async: true do
  test "part 1 input" do
    assert Y2015.D5.p1(input_string()) == 255
  end

  test "part 2 input" do
    assert Y2015.D5.p2(input_string()) == 55
  end
end
