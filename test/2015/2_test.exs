import AOC

aoc_test 2015, 2, async: true do
  test "part 1 input" do
    assert Y2015.D2.p1(input_string()) == 1_606_483
  end

  test "part 2 input" do
    assert Y2015.D2.p2(input_string()) == 3_842_356
  end
end
