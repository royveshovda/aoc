import AOC

aoc_test 2018, 22, async: true do
  test "part 1 input" do
    assert Y2018.D22.p1(input_string()) == 8575
  end

  test "part 2 input" do
    assert Y2018.D22.p2(input_string()) == 999
  end
end
