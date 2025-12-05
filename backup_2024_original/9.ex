import AOC

aoc 2024, 9 do
  @moduledoc """
  https://adventofcode.com/2024/day/9
  Source: https://github.com/liamcmitchell/advent-of-code/blob/main/2024/09/1.exs
  """

  def p1(input) do
    input
    |> parse()
    |> compact()
    |> checksum()
  end

  def p2(input) do
    input
    |> parse_files()
    |> compact_files()
    |> files_to_disk()
    |> checksum()
  end

  def parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.flat_map(fn {char, index} ->
      length = String.to_integer(char)
      id = if rem(index, 2) == 0, do: div(index, 2), else: -1
      List.duplicate(id, length)
    end)
  end

  def compact(disk) do
    to_move = Enum.reverse(disk) |> Enum.filter(&(&1 != -1))
    total = Enum.count(disk)
    used = Enum.count(to_move)
    unused = total - used
    compact(Enum.slice(disk, 0, used), Enum.slice(to_move, 0, unused))
  end

  def compact([], _), do: []

  def compact([block | rest], to_move) do
    if block == -1 do
      [hd(to_move) | compact(rest, tl(to_move))]
    else
      [block | compact(rest, to_move)]
    end
  end

  def checksum(disk) do
    disk
    |> Enum.with_index()
    |> Enum.reduce(0, fn {id, index}, acc ->
      if id == -1, do: acc, else: acc + id * index
    end)
  end

  def part1(file) do
    parse(file) |> compact() |> checksum()
  end

  # Part 2
  def parse_files(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {char, index} ->
      length = String.to_integer(char)
      id = if rem(index, 2) == 0, do: div(index, 2), else: -1
      {id, length}
    end)
  end

  def compact_files(files) do
    compact_files(files, Enum.reverse(files))
  end

  def compact_files(files, []), do: files

  def compact_files(files, [moving | to_move]) do
    compact_files(move_file(files, moving), to_move)
  end

  def move_file([], _), do: []
  def move_file(files, {moving_id, _}) when moving_id == -1, do: files

  def move_file([file | files], moving) do
    if file == moving do
      [file | files]
    else
      {file_id, file_length} = file
      {moving_id, moving_length} = moving

      if file_id == -1 and file_length >= moving_length do
        [moving, {-1, file_length - moving_length} | remove_file(files, {moving_id, moving_length})]
      else
        [file | move_file(files, moving)]
      end
    end
  end

  def remove_file([], _), do: []

  def remove_file([file | files], remove) do
    if file == remove do
      [{-1, elem(remove, 1)} | files]
    else
      [file | remove_file(files, remove)]
    end
  end

  def files_to_disk(files) do
    Enum.flat_map(files, fn {id, length} -> List.duplicate(id, length) end)
  end
end
