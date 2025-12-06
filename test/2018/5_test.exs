import AOC

aoc_test 2018, 5, async: true do
  @tag :skip
  test "part 1 input" do
    assert Y2018.D5.p1(input_string()) == 10180
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D5.p2(input_string()) == 5668
  end
end
