import AOC

aoc_test 2017, 6, async: true do
  test "part 1 input" do
    assert Y2017.D6.p1(input_string()) == 11137
  end

  test "part 2 input" do
    assert Y2017.D6.p2(input_string()) == 1037
  end
end
