import AOC

aoc_test 2018, 3, async: true do
  @tag :skip
  test "part 1 input" do
    assert Y2018.D3.p1(input_string()) == 107_663
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D3.p2(input_string()) == 1166
  end
end
