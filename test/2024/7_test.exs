import AOC

aoc_test 2024, 7, async: true do
  def get_example_string() do
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """
  end
  test "p1e" do
    assert Y2024.D7.p1(get_example_string()) == 3749
  end

  test "p1i" do
    assert Y2024.D7.p1(input_string()) == 5_512_534_574_980
  end

  test "p2e" do
    assert Y2024.D7.p2(get_example_string()) == 11_387
  end

  test "p2i" do
    assert Y2024.D7.p2(input_string()) == 328_790_210_468_594
  end
end
