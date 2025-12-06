import AOC

aoc 2022, 7 do
  @moduledoc """
  Day 7: No Space Left On Device

  Parse terminal output to build filesystem tree.
  Part 1: Sum of directory sizes <= 100000.
  Part 2: Find smallest directory to delete to free space.
  """

  @doc """
  Part 1: Sum sizes of directories with total size <= 100000.

  ## Examples

      iex> example = "$ cd /\\n$ ls\\ndir a\\n14848514 b.txt\\n8504156 c.dat\\ndir d\\n$ cd a\\n$ ls\\ndir e\\n29116 f\\n2557 g\\n62596 h.lst\\n$ cd e\\n$ ls\\n584 i\\n$ cd ..\\n$ cd ..\\n$ cd d\\n$ ls\\n4060174 j\\n8033020 d.log\\n5626152 d.ext\\n7214296 k"
      iex> p1(example)
      95437
  """
  def p1(input) do
    dir_sizes = build_dir_sizes(input)

    dir_sizes
    |> Map.values()
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  @doc """
  Part 2: Find size of smallest directory to delete (need 30M free of 70M total).

  ## Examples

      iex> example = "$ cd /\\n$ ls\\ndir a\\n14848514 b.txt\\n8504156 c.dat\\ndir d\\n$ cd a\\n$ ls\\ndir e\\n29116 f\\n2557 g\\n62596 h.lst\\n$ cd e\\n$ ls\\n584 i\\n$ cd ..\\n$ cd ..\\n$ cd d\\n$ ls\\n4060174 j\\n8033020 d.log\\n5626152 d.ext\\n7214296 k"
      iex> p2(example)
      24933642
  """
  def p2(input) do
    dir_sizes = build_dir_sizes(input)

    total_space = 70_000_000
    needed_space = 30_000_000
    used_space = dir_sizes["/"]
    free_space = total_space - used_space
    need_to_free = needed_space - free_space

    dir_sizes
    |> Map.values()
    |> Enum.filter(&(&1 >= need_to_free))
    |> Enum.min()
  end

  defp build_dir_sizes(input) do
    {_, dir_sizes} =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce({[], %{}}, fn line, {cwd, dir_sizes} ->
        cond do
          String.starts_with?(line, "$ cd /") ->
            {["/"], Map.put_new(dir_sizes, "/", 0)}

          String.starts_with?(line, "$ cd ..") ->
            {tl(cwd), dir_sizes}

          String.starts_with?(line, "$ cd ") ->
            dir_name = String.slice(line, 5..-1//1)
            new_path = path_for(cwd, dir_name)
            {[new_path | cwd], Map.put_new(dir_sizes, new_path, 0)}

          String.starts_with?(line, "$ ls") ->
            {cwd, dir_sizes}

          String.starts_with?(line, "dir ") ->
            {cwd, dir_sizes}

          true ->
            # File: "size filename"
            [size_str, _name] = String.split(line, " ", parts: 2)
            size = String.to_integer(size_str)

            # Add size to current dir and all parent dirs
            dir_sizes =
              Enum.reduce(cwd, dir_sizes, fn dir, acc ->
                Map.update!(acc, dir, &(&1 + size))
              end)

            {cwd, dir_sizes}
        end
      end)

    dir_sizes
  end

  defp path_for(["/"], name), do: "/" <> name
  defp path_for([current | _], name), do: current <> "/" <> name
end
