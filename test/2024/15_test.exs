import AOC

aoc_test 2024, 15, async: true do
  def get_example_string_small() do
    """
    ########
    #..O.O.#
    ##@.O..#
    #...O..#
    #.#.O..#
    #...O..#
    #......#
    ########

    <^^>>>vv<v>>v<<
    """
  end

  test "p1e" do
    assert Y2024.D15.p1(get_example_string_small()) == 2028
  end

  test "p1i" do
    assert Y2024.D15.p1(input_string()) == 1_563_092
  end

  # test "p2e" do
  #   assert Y2024.D15.p2(example_string()) == 1
  # end

  # test "p2i" do
  #   assert Y2024.D15.p2(input_string()) == 1
  # end
end
