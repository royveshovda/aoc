import AOC

aoc_test 2023, 13, async: true do
  test "get lines to compare" do
    assert Y2023.D13.get_pairs_for_line(1,5) == {1, [{0,1}]}
    assert Y2023.D13.get_pairs_for_line(2,5) == {2, [{0,3}, {1,2}]}
    assert Y2023.D13.get_pairs_for_line(3,5) == {3, [{0,5}, {1,4}, {2,3}]}
    assert Y2023.D13.get_pairs_for_line(4,5) == {4, [{2,5}, {3,4}]}
  end
end
