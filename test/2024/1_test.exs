import AOC

aoc_test 2024, 1, async: true do

  def get_example_string() do
    """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """
  end
  test "p1e" do
    assert Y2024.D1.p1(get_example_string()) == 11
  end

  test "p1i" do
    assert Y2024.D1.p1(input_string()) == 1_651_298
  end

  test "p2e" do
    assert Y2024.D1.p2(get_example_string()) == 31
  end

  test "p2i" do
    assert Y2024.D1.p2(input_string()) == 21_306_195
  end
end
