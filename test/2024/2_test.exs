import AOC

aoc_test 2024, 2, async: true do
  def get_example_string() do
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9

    """
  end
  test "p1e" do
    assert Y2024.D2.p1(get_example_string()) == 2
  end

  test "p1i" do
    assert Y2024.D2.p1(input_string()) == 639
  end

  test "p2e" do
    assert Y2024.D2.p2(get_example_string()) == 4
  end

  test "p2i" do
    assert Y2024.D2.p2(input_string()) == 674
  end
end
