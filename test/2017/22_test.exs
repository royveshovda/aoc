import AOC

aoc_test 2017, 22, async: true do
  test "part 1 input" do
    assert Y2017.D22.p1(input_string()) == 5404
  end

  test "part 2 input" do
    assert Y2017.D22.p2(input_string()) == 2_511_672
  end
end
