import AOC

aoc_test 2023, 10, async: true do
  test "step north and into |" do
    assert step({3,2}, {{2,2}, "|"}) == {1,2}
  end

  test "step north and into F" do
    assert step({3,2}, {{2,2}, "F"}) == {2,3}
  end

  test "step north and into 7" do
    assert step({3,2}, {{2,2}, "7"}) == {2,1}
  end

  test "step south and into |" do
    assert step({1,2}, {{2,2}, "|"}) == {3,2}
  end

  test "step south and into L" do
    assert step({1,2}, {{2,2}, "L"}) == {2,3}
  end

  test "step south and into J" do
    assert step({1,2}, {{2,2}, "J"}) == {2,1}
  end

  test "step west and into -" do
    assert step({2,3}, {{2,2}, "-"}) == {2,1}
  end

  test "step west and into L" do
    assert step({2,3}, {{2,2}, "L"}) == {1,2}
  end

  test "step west and into F" do
    assert step({2,3}, {{2,2}, "F"}) == {3,2}
  end


  test "step east and into -" do
    assert step({2,1}, {{2,2}, "-"}) == {2,3}
  end

  test "step east and into J" do
    assert step({2,1}, {{2,2}, "J"}) == {1,2}
  end

  test "step east and into 7" do
    assert step({2,1}, {{2,2}, "7"}) == {3,2}
  end

  test "count line segments: |" do
    assert count_line_segments([{{1,1}, "-"},{{1,2}, "|"},{{1,3}, "F"}]) == 1
    assert count_line_segments([{{1,1}, "-"},{{1,2}, "|"},{{1,3}, "-"}, {{1,4},"|"}, {{1,5}, "7"}]) == 2
  end

  test "count line segments: L,7" do
    assert count_line_segments([{{1,3}, "L"}, {{1,4}, "7"}]) == 1
  end

  test "count line segments: L,-,7" do
    assert count_line_segments([{{1,2}, "L"}, {{1,3}, "-"}, {{1,4}, "7"}]) == 1
  end

  test "count line segments: L,-,-,-,7" do
    assert count_line_segments([{{1,1}, "-"},{{1,2}, "L"}, {{1,3}, "-"}, {{1,4}, "-"}, {{1,5}, "-"}, {{1,6}, "7"}, {{1,7}, "-"}]) == 1
  end

  test "count line segments: F,J" do
    assert count_line_segments([{{1,3}, "F"}, {{1,4}, "J"}]) == 1
  end

  test "count line segments: F,-,J" do
    assert count_line_segments([{{1,2}, "F"}, {{1,3}, "-"}, {{1,4}, "J"}]) == 1
  end

  test "count line segments: F,-,-,-,J" do
    assert count_line_segments([{{1,1}, "-"},{{1,2}, "F"}, {{1,3}, "-"}, {{1,4}, "-"}, {{1,5}, "-"}, {{1,6}, "J"}, {{1,7}, "-"}]) == 1
  end
end
