import AOC

aoc_test 2018, 4, async: true do
  @tag :skip
  test "part 1 input" do
    assert Y2018.D4.p1(input_string()) == 35184
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D4.p2(input_string()) == 37886
  end
end
