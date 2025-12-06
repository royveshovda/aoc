import AOC

aoc_test 2016, 3, async: true do
  test "part 1 input" do
    assert Y2016.D3.p1(input_string()) == 1032
  end

  test "part 2 input" do
    assert Y2016.D3.p2(input_string()) == 1838
  end
end
