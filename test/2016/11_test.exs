import AOC

aoc_test 2016, 11, async: true do
  test "part 1 input" do
    assert Y2016.D11.p1(input_string()) == 47
  end

  test "part 2 input" do
    assert Y2016.D11.p2(input_string()) == 71
  end
end
