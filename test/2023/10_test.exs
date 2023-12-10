import AOC

aoc_test 2023, 10, async: true do
  test "step north and into |" do
    assert step({1,2}, {{2,2}, "|"}) == {3,2}
  end

  test "step north and into F" do
    assert step({1,2}, {{2,2}, "F"}) == {2,3}
  end

  test "step north and into 7" do
    assert step({1,2}, {{2,2}, "7"}) == {2,1}
  end

  test "step south and into |" do
    assert step({3,2}, {{2,2}, "|"}) == {1,2}
  end

  test "step south and into L" do
    assert step({3,2}, {{2,2}, "L"}) == {2,3}
  end

  test "step south and into J" do
    assert step({3,2}, {{2,2}, "J"}) == {2,1}
  end

  test "step west and into -" do
    assert step({2,3}, {{2,2}, "-"}) == {2,1}
  end

  test "step west and into L" do
    assert step({2,3}, {{2,2}, "L"}) == {3,2}
  end

  test "step west and into F" do
    assert step({2,3}, {{2,2}, "F"}) == {1,2}
  end

  test "step east and into -" do
    assert step({2,1}, {{2,2}, "-"}) == {2,3}
  end

  test "step east and into J" do
    assert step({2,1}, {{2,2}, "J"}) == {3,2}
  end

  test "step east and into 7" do
    assert step({2,1}, {{2,2}, "7"}) == {1,2}
  end
end
