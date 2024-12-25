import AOC

aoc 2024, 25 do
  @moduledoc """
  https://adventofcode.com/2024/day/25

  Prompt:

  Elixir
  Can you solve the following problem in elixir, taking input from a txt file? Prioritize accuracy in algorithm over speed. Make sure the code has valid elixir syntax, and can run. I need a full working example in a single exs file.
  """

  def p1(input) do

    # Read and parse all schematics
    lines =
      input
      |> String.split("\n", trim: true)

    # Group every 7 lines into a single schematic
    schematics = Enum.chunk_every(lines, 7)

    # Parse each schematic into either lock or key heights
    {locks, keys} =
      schematics
      |> Enum.map(&parse_schematic/1)
      |> Enum.split_with(fn {type, _heights} -> type == :lock end)

    # `locks` and `keys` are each lists of {type, heights}, but for counting
    # we only need the heights. The type is either :lock or :key.
    lock_heights = Enum.map(locks, fn {_type, h} -> h end)
    key_heights  = Enum.map(keys,  fn {_type, h} -> h end)

    # Count how many unique lock/key pairs fit
    count_valid_pairs(lock_heights, key_heights)
  end

  # ----------------------------------------------------------------------------
    # Parsing

    @doc """
    Given a 7-line schematic (each line is 5 chars of '#' or '.'),
    determine if it's a lock or a key, and convert it to a list of heights.
    """
    def parse_schematic(lines_of_5) do
      top_line    = hd(lines_of_5)
      bottom_line = List.last(lines_of_5)

      cond do
        # Lock: top row is all '#' and bottom row is all '.'
        top_line == "#####" and bottom_line == "....." ->
          {:lock, parse_heights_for_lock(lines_of_5)}

        # Key: top row is all '.' and bottom row is all '#'
        top_line == "....." and bottom_line == "#####" ->
          {:key, parse_heights_for_key(lines_of_5)}

        true ->
          raise "Unrecognized schematic type:\n" <>
                Enum.join(lines_of_5, "\n") <> "\n"
      end
    end

    @doc """
    Convert a lock schematic (7 lines, 5 columns) into a list of pin heights,
    counting '#' from the top down each column.
    """
    def parse_heights_for_lock(lines_of_5) do
      # lines_of_5 is a list of strings, each 5 characters: '#' or '.'
      # We'll produce [h0, h1, h2, h3, h4], where hi is how many '#' from the top.
      for col <- 0..4 do
        count_pins_down(lines_of_5, col)
      end
    end

    @doc """
    Convert a key schematic (7 lines, 5 columns) into a list of pin heights,
    counting '#' from the bottom up each column.
    """
    def parse_heights_for_key(lines_of_5) do
      for col <- 0..4 do
        count_pins_up(lines_of_5, col)
      end
    end

    @doc """
    Counts how many '#' in a given column from the top until we encounter '.'.
    """
    def count_pins_down(lines_of_5, col) do
      lines_of_5
      |> Enum.reduce_while(0, fn line, acc ->
        if String.at(line, col) == "#" do
          {:cont, acc + 1}
        else
          {:halt, acc}
        end
      end)
    end

    @doc """
    Counts how many '#' in a given column from the bottom until we encounter '.'.
    """
    def count_pins_up(lines_of_5, col) do
      # We start from the bottom (index 6) and move upwards
      lines_of_5
      |> Enum.reverse()
      |> Enum.reduce_while(0, fn line, acc ->
        if String.at(line, col) == "#" do
          {:cont, acc + 1}
        else
          {:halt, acc}
        end
      end)
    end

    # ----------------------------------------------------------------------------
    # Checking overlap

    @doc """
    Returns how many (lock, key) pairs do *not* overlap. Overlap means
    the sum of heights in any column is greater than 7 (the total row count).
    """
    def count_valid_pairs(locks, keys) do
      Enum.reduce(locks, 0, fn lock_heights, acc ->
        acc + Enum.count(keys, fn key_heights -> fits?(lock_heights, key_heights) end)
      end)
    end

    @doc """
    True if for every column, lock_height + key_height <= 7.
    """
    def fits?(lock_heights, key_heights) do
      Enum.zip(lock_heights, key_heights)
      |> Enum.all?(fn {lh, kh} -> lh + kh <= 7 end)
    end
end
