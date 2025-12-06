import AOC

aoc_test 2015, 12, async: true do
  test "part 1 input" do
    assert Y2015.D12.p1(input_string()) == 191_164
  end

  test "part 2 input" do
    assert Y2015.D12.p2(input_string()) == 87842
  end
end
