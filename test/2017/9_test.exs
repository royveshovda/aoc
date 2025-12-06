import AOC

aoc_test 2017, 9, async: true do
  test "part 1 input" do
    assert Y2017.D9.p1(input_string()) == 20530
  end

  test "part 2 input" do
    assert Y2017.D9.p2(input_string()) == 9978
  end
end
