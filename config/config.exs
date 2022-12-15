import Config

aoc_token =
  System.get_env("AOC_TOKEN") ||
    raise """
    environment variable AOC_TOKEN is missing.
    """

config :advent_of_code_utils,
  auto_compile?: true,
  #time_zone: :aoc,
  session: aoc_token

config :iex,
  inspect: [charlists: :as_lists]
