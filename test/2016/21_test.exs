import AOC

aoc_test 2016, 21, async: true do
  test "part 1 input" do
    assert Y2016.D21.p1(input_string()) == "bgfacdeh"
  end

  test "part 2 input" do
    assert Y2016.D21.p2(input_string()) == "bdgheacf"
  end
end
