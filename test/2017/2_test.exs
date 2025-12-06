import AOC

aoc_test 2017, 2, async: true do
  test "part 1 input" do
    assert Y2017.D2.p1(input_string()) == 51139
  end

  test "part 2 input" do
    assert Y2017.D2.p2(input_string()) == 272
  end
end
