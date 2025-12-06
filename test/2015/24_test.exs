import AOC

aoc_test 2015, 24, async: true do
  test "part 1 input" do
    assert Y2015.D24.p1(input_string()) == 10_439_961_859
  end

  test "part 2 input" do
    assert Y2015.D24.p2(input_string()) == 72_050_269
  end
end
