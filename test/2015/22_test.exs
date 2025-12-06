import AOC

aoc_test 2015, 22, async: true do
  test "part 1 input" do
    assert Y2015.D22.p1(input_string()) == 900
  end

  test "part 2 input" do
    assert Y2015.D22.p2(input_string()) == 1216
  end
end
