import AOC

aoc_test 2017, 12, async: true do
  test "part 1 input" do
    assert Y2017.D12.p1(input_string()) == 288
  end

  test "part 2 input" do
    assert Y2017.D12.p2(input_string()) == 211
  end
end
