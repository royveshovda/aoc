import AOC

aoc_test 2017, 3, async: true do
  test "part 1 input" do
    assert Y2017.D3.p1(input_string()) == 430
  end

  test "part 2 input" do
    assert Y2017.D3.p2(input_string()) == 312_453
  end
end
