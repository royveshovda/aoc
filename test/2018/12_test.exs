import AOC

aoc_test 2018, 12, async: true do
  test "part 1 input" do
    assert Y2018.D12.p1(input_string()) == 3061
  end

  test "part 2 input" do
    assert Y2018.D12.p2(input_string()) == 4_049_999_998_575
  end
end
