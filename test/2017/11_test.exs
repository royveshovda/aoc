import AOC

aoc_test 2017, 11, async: true do
  test "part 1 input" do
    assert Y2017.D11.p1(input_string()) == 696
  end

  test "part 2 input" do
    assert Y2017.D11.p2(input_string()) == 1461
  end
end
