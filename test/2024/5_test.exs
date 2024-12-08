import AOC

aoc_test 2024, 5, async: true do
  def get_example_string() do
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  end
  test "p1e" do
    assert Y2024.D5.p1(get_example_string()) == 143
  end

  test "p1i" do
    assert Y2024.D5.p1(input_string()) == 5208
  end

  test "p2e" do
    assert Y2024.D5.p2(get_example_string()) == 123
  end

  test "p2i" do
    assert Y2024.D5.p2(input_string()) == 6732
  end
end
