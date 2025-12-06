import AOC

aoc_test 2017, 18, async: true do
  test "part 1 input" do
    assert Y2017.D18.p1(input_string()) == 2951
  end

  test "part 2 input" do
    assert Y2017.D18.p2(input_string()) == 7366
  end
end
