import AOC

aoc_test 2025, 11, async: true do
	test "p1 example" do
		input = example_string(0)
		assert p1(input) == 5
	end

	test "p1 real input" do
		input = File.read!("input/2025_11.txt")
		assert p1(input) == 786
	end

	test "p2 example" do
		input = example_string(1)
		assert p2(input) == 2
	end

	test "p2 real input" do
		input = File.read!("input/2025_11.txt")
		assert p2(input) == 495845045016588
	end
end
