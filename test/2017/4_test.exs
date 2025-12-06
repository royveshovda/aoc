import AOC

aoc_test 2017, 4, async: true do
  test "part 1 input" do
    assert Y2017.D4.p1(input_string()) == 337
  end

  test "part 2 input" do
    assert Y2017.D4.p2(input_string()) == 231
  end
end
