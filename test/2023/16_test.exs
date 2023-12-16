import AOC

aoc_test 2023, 16, async: true do
  test "Move right into ." do
    assert Y2023.D16.move({:right, 1, 1}, ".", {10,10}) == [{:right, 1, 2}]
  end

  test "Move left into ." do
    assert Y2023.D16.move({:left, 1, 1}, ".", {10,10}) == [{:left, 1, 0}]
  end

  test "Move down into ." do
    assert Y2023.D16.move({:down, 1, 1}, ".", {10,10}) == [{:down, 2, 1}]
  end

  test "Move up into ." do
    assert Y2023.D16.move({:up, 1, 1}, ".", {10,10}) == [{:up, 0, 1}]
  end

  test "Move right into . with roll over" do
    assert Y2023.D16.move({:right, 1, 10}, ".", {10,10}) == [{:right, 1, 0}]
  end

  test "Move left into . with roll over" do
    assert Y2023.D16.move({:left, 1, 0}, ".", {10,10}) == [{:left, 1, 10}]
  end

  test "Move down into . with roll over" do
    assert Y2023.D16.move({:down, 10, 1}, ".", {10,10}) == [{:down, 0, 1}]
  end

  test "Move up into . with roll over" do
    assert Y2023.D16.move({:up, 0, 1}, ".", {10,10}) == [{:up, 10, 1}]
  end

  test "Move right into /" do
    assert Y2023.D16.move({:right, 1, 1}, "/", {10,10}) == [{:up, 0, 1}]
  end

  test "Move left into /" do
    assert Y2023.D16.move({:left, 1, 1}, "/", {10,10}) == [{:down, 2, 1}]
  end

  test "Move down into /" do
    assert Y2023.D16.move({:down, 1, 1}, "/", {10,10}) == [{:left, 1, 0}]
  end

  test "Move up into /" do
    assert Y2023.D16.move({:up, 1, 1}, "/", {10,10}) == [{:right, 1, 2}]
  end

  test "Move right into \\" do
    assert Y2023.D16.move({:right, 1, 1}, "\\", {10,10}) == [{:down, 2, 1}]
  end

  test "Move left into \\" do
    assert Y2023.D16.move({:left, 1, 1}, "\\", {10,10}) == [{:up, 0, 1}]
  end

  test "Move down into \\" do
    assert Y2023.D16.move({:down, 1, 1}, "\\", {10,10}) == [{:right, 1, 2}]
  end

  test "Move up into \\" do
    assert Y2023.D16.move({:up, 1, 1}, "\\", {10,10}) == [{:left, 1, 0}]
  end

  test "Move right into -" do
    assert Y2023.D16.move({:right, 1, 1}, "-", {10,10}) == [{:right, 1, 2}]
  end

  test "Move left into -" do
    assert Y2023.D16.move({:left, 1, 1}, "-", {10,10}) == [{:left, 1, 0}]
  end

  test "Move down into -" do
    assert Y2023.D16.move({:down, 1, 1}, "-", {10,10}) == [{:left, 1, 0}, {:right, 1, 2}]
  end

  test "Move up into -" do
    assert Y2023.D16.move({:up, 1, 1}, "-", {10,10}) == [{:left, 1, 0}, {:right, 1, 2}]
  end

  test "Move right into |" do
    assert Y2023.D16.move({:right, 1, 1}, "|", {10,10}) == [{:up, 0, 1}, {:down, 2, 1}]
  end

  test "Move left into |" do
    assert Y2023.D16.move({:left, 1, 1}, "|", {10,10}) == [{:up, 0, 1}, {:down, 2, 1}]
  end

  test "Move down into |" do
    assert Y2023.D16.move({:down, 1, 1}, "|", {10,10}) == [{:down, 2, 1}]
  end

  test "Move up into |" do
    assert Y2023.D16.move({:up, 1, 1}, "|", {10,10}) == [{:up, 0, 1}]
  end
end
