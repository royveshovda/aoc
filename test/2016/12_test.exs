import AOC

aoc_test 2016, 12, async: true do
  test "part 1 input" do
    assert Y2016.D12.p1(input_string()) == 318_020
  end

  test "part 2 input" do
    assert Y2016.D12.p2(input_string()) == 9_227_674
  end
end
