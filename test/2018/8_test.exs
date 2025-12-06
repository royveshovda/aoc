import AOC

aoc_test 2018, 8, async: true do
  @tag :skip
  test "part 1 input" do
    assert Y2018.D8.p1(input_string()) == 40977
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D8.p2(input_string()) == 27490
  end
end
