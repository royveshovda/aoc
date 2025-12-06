import AOC

aoc_test 2015, 16, async: true do
  test "part 1 input" do
    assert Y2015.D16.p1(input_string()) == 213
  end

  test "part 2 input" do
    assert Y2015.D16.p2(input_string()) == 323
  end
end
