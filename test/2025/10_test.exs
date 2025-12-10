import AOC

aoc_test 2025, 10, async: true do
	test "part 1 example" do
		assert Y2025.D10.p1(example_string()) == 7
	end

	test "part 1 with input" do
		assert Y2025.D10.p1(input_string()) == 385
	end

	test "part 2 example" do
		assert Y2025.D10.p2(example_string()) == 33
	end

	test "part 2 with input" do
		assert Y2025.D10.p2(input_string()) == 16757
	end
end
