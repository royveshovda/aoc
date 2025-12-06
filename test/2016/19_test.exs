import AOC

aoc_test 2016, 19, async: true do
  test "part 1 input" do
    assert Y2016.D19.p1(input_string()) == 1_830_117
  end

  test "part 2 input" do
    assert Y2016.D19.p2(input_string()) == 1_417_887
  end
end
