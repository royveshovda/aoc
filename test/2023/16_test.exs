import AOC

aoc_test 2023, 16, async: true do
  test "Move right into ." do
    assert Y2023.D16.move({:right, 1, 1}, ".") == [{:right, 1, 2}]
  end

  test "Move left into ." do
    assert Y2023.D16.move({:left, 1, 1}, ".") == [{:left, 1, 0}]
  end

  test "Move down into ." do
    assert Y2023.D16.move({:down, 1, 1}, ".") == [{:down, 2, 1}]
  end

  test "Move up into ." do
    assert Y2023.D16.move({:up, 1, 1}, ".") == [{:up, 0, 1}]
  end

  test "Move right into /" do
    assert Y2023.D16.move({:right, 1, 1}, "/") == [{:up, 0, 1}]
  end

  test "Move left into /" do
    assert Y2023.D16.move({:left, 1, 1}, "/") == [{:down, 2, 1}]
  end

  test "Move down into /" do
    assert Y2023.D16.move({:down, 1, 1}, "/") == [{:left, 1, 0}]
  end

  test "Move up into /" do
    assert Y2023.D16.move({:up, 1, 1}, "/") == [{:right, 1, 2}]
  end

  test "Move right into \\" do
    assert Y2023.D16.move({:right, 1, 1}, "\\") == [{:down, 2, 1}]
  end

  test "Move left into \\" do
    assert Y2023.D16.move({:left, 1, 1}, "\\") == [{:up, 0, 1}]
  end

  test "Move down into \\" do
    assert Y2023.D16.move({:down, 1, 1}, "\\") == [{:right, 1, 2}]
  end

  test "Move up into \\" do
    assert Y2023.D16.move({:up, 1, 1}, "\\") == [{:left, 1, 0}]
  end

  test "Move right into -" do
    assert Y2023.D16.move({:right, 1, 1}, "-") == [{:right, 1, 2}]
  end

  test "Move left into -" do
    assert Y2023.D16.move({:left, 1, 1}, "-") == [{:left, 1, 0}]
  end

  test "Move down into -" do
    assert Y2023.D16.move({:down, 1, 1}, "-") == [{:left, 1, 0}, {:right, 1, 2}]
  end

  test "Move up into -" do
    assert Y2023.D16.move({:up, 1, 1}, "-") == [{:left, 1, 0}, {:right, 1, 2}]
  end

  test "Move right into |" do
    assert Y2023.D16.move({:right, 1, 1}, "|") == [{:up, 0, 1}, {:down, 2, 1}]
  end

  test "Move left into |" do
    assert Y2023.D16.move({:left, 1, 1}, "|") == [{:up, 0, 1}, {:down, 2, 1}]
  end

  test "Move down into |" do
    assert Y2023.D16.move({:down, 1, 1}, "|") == [{:down, 2, 1}]
  end

  test "Move up into |" do
    assert Y2023.D16.move({:up, 1, 1}, "|") == [{:up, 0, 1}]
  end
end
