import AOC

aoc_test 2018, 9, async: true do
  @tag :skip
  test "part 1 input" do
    assert Y2018.D9.p1(input_string()) == 382055
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D9.p2(input_string()) == 3_133_277_384
  end
end
