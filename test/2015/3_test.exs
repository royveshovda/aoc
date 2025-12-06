import AOC

aoc_test 2015, 3, async: true do
  test "part 1 input" do
    assert Y2015.D3.p1(input_string()) == 2565
  end

  test "part 2 input" do
    assert Y2015.D3.p2(input_string()) == 2639
  end
end
