import AOC

aoc_test 2021, 16, async: true do
  test "part 1 example 1" do
    assert Y2021.D16.p1("8A004A801A8002F478") == 16
  end

  test "part 1 example 2" do
    assert Y2021.D16.p1("620080001611562C8802118E34") == 12
  end

  test "part 1 input" do
    assert Y2021.D16.p1(input_string()) == 897
  end

  test "part 2 example sum" do
    assert Y2021.D16.p2("C200B40A82") == 3
  end

  test "part 2 example product" do
    assert Y2021.D16.p2("04005AC33890") == 54
  end

  test "part 2 input" do
    assert Y2021.D16.p2(input_string()) == 9_485_076_995_911
  end
end
