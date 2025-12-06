import AOC

aoc_test 2018, 2, async: true do
  @tag :skip
  test "part 1 input" do
    assert Y2018.D2.p1(input_string()) == 8820
  end

  @tag :skip
  test "part 2 input" do
    assert Y2018.D2.p2(input_string()) == "bpacnmglhizqygfsjixtkwudr"
  end
end
