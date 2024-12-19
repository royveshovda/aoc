import AOC

aoc_test 2024, 17, async: true do
  def get_example_string_1() do
    """
    Register A: 0
    Register B: 0
    Register C: 9

    Program: 2,6
    """
  end

  def get_example_string_2() do
    # If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2.
    """
    Register A: 10
    Register B: 0
    Register C: 9

    Program: 0,1,5,4,3,0
    """
  end

  def get_example_string_3() do
    # If register A contains 2024, the program 0,1,5,4,3,0 would output 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A.
    """
    Register A: 2024
    Register B: 0
    Register C: 9

    Program: 0,1,5,4,3,0
    """
  end

  def get_example_string_4() do
    """
    Register A: 2024
    Register B: 0
    Register C: 0

    Program: 0,3,5,4,3,0
    """
  end

  test "p1e_1" do
    assert Y2024.D17.p1(get_example_string_1()) == ""
  end

  test "p1e_3" do
    assert Y2024.D17.p1(get_example_string_3()) == "4,2,5,6,7,7,7,7,3,1,0"
  end

  test "p1e" do
    assert Y2024.D17.p1(example_string()) == "4,6,3,5,6,3,5,2,1,0"
  end

  test "p1i" do
    assert Y2024.D17.p1(input_string()) == "3,4,3,1,7,6,5,6,0"
  end

  test "p2e" do
    assert Y2024.D17.p2(get_example_string_4()) == 117_440
  end

  test "p2i" do
    assert Y2024.D17.p2(input_string()) == 109_019_930_331_546
  end
end
