import Config

try do
  File.stream!("./.env")
    |> Stream.map(&String.trim_trailing/1) # remove excess whitespace
    |> Enum.each(fn line -> line           # loop through each line
      |> String.replace("export ", "")     # remove "export" from line
      |> String.split("=")                 # split on the "=" (equals sign)
      |> Enum.reduce(fn(value, key) ->     # stackoverflow.com/q/33055834/1148249
        System.put_env(key, value)         # set each environment variable
      end)
    end)
rescue
  _ -> IO.puts "no .env file found!"
end

aoc_token =
  System.get_env("AOC_TOKEN") ||
    raise """
    environment variable AOC_TOKEN is missing.
    """

config :advent_of_code_utils,
  auto_compile?: true,
  #time_zone: :aoc,
  session: aoc_token

# config :iex,
#   inspect: [charlists: :as_lists]
