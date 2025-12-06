import AOC

aoc_test 2018, 6, async: true do
  @tag :skip
  test "part 1 input" do
    assert Y2018.D6.p1(input_string()) == 3290
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D6.p2(input_string()) == 45602
  end
end
