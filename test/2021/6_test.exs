import AOC

aoc_test 2021, 6, async: true do
  @example "3,4,3,1,2"

  test "part 1 example" do
    assert Y2021.D6.p1(@example) == 5934
  end

  test "part 1 input" do
    assert Y2021.D6.p1(input_string()) == 374_927
  end

  test "part 2 example" do
    assert Y2021.D6.p2(@example) == 26_984_457_539
  end

  test "part 2 input" do
    assert Y2021.D6.p2(input_string()) == 1_687_617_803_407
  end
end
