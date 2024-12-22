import AOC

aoc_test 2024, 20, async: true do
  def get_example() do
    """
    ###############
    #...#...#.....#
    #.#.#.#.#.###.#
    #S#...#.#.#...#
    #######.#.#.###
    #######.#.#...#
    #######.#.###.#
    ###..E#...#...#
    ###.#######.###
    #...###...#...#
    #.#####.#.###.#
    #.#...#.#.#...#
    #.#.#.#.#.#.###
    #...#...#...###
    ###############
    """
  end
  test "p1e" do
    assert Y2024.D20.p1(get_example()) == 0
  end

  test "p1i" do
    assert Y2024.D20.p1(input_string()) == 1351
  end

  test "p2e" do
    assert Y2024.D20.p2(get_example()) == 0
  end

  test "p2i" do
    assert Y2024.D20.p2(input_string()) == 966_130
  end
end
