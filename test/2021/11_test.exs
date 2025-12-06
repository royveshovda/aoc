import AOC

aoc_test 2021, 11, async: true do
  @example "5483143223\n2745854711\n5264556173\n6141336146\n6357385478\n4167524645\n2176841721\n6882881134\n4846848554\n5283751526"

  test "part 1 example" do
    assert Y2021.D11.p1(@example) == 1656
  end

  test "part 1 input" do
    assert Y2021.D11.p1(input_string()) == 1667
  end

  test "part 2 example" do
    assert Y2021.D11.p2(@example) == 195
  end

  test "part 2 input" do
    assert Y2021.D11.p2(input_string()) == 488
  end
end
