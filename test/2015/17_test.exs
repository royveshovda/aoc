import AOC

aoc_test 2015, 17, async: true do
  test "part 1 input" do
    assert Y2015.D17.p1(input_string()) == 654
  end

  test "part 2 input" do
    assert Y2015.D17.p2(input_string()) == 57
  end
end
