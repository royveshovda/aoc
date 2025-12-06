import AOC

aoc_test 2018, 20, async: true do
  test "part 1 input" do
    assert Y2018.D20.p1(input_string()) == 4239
  end

  test "part 2 input" do
    assert Y2018.D20.p2(input_string()) == 8205
  end
end
