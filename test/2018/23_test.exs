import AOC

aoc_test 2018, 23, async: true do
  test "part 1 input" do
    assert Y2018.D23.p1(input_string()) == 943
  end

  test "part 2 input" do
    assert Y2018.D23.p2(input_string()) == 84_087_816
  end
end
