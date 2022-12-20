import Bitwise

defmodule Day17 do
  defmodule RockPattern do
    def new(lines) do
      for line <- lines do
        String.codepoints(line)
          |> Enum.reverse()
          |> Enum.with_index(&parse/2)
          |> Enum.sum()
      end
    end
    defp parse(".", _), do: 0
    defp parse("#", index), do: Integer.pow(2, index)
  end

  defmodule Rocks do
    defstruct [:index]
    @patterns {
      RockPattern.new([
        "..####."
      ]),
      RockPattern.new([
        "...#...",
        "..###..",
        "...#..."
      ]),
      RockPattern.new([
        "....#..",
        "....#..",
        "..###.."
      ]),
      RockPattern.new([
        "..#....",
        "..#....",
        "..#....",
        "..#...."
      ]),
      RockPattern.new([
        "..##...",
        "..##..."
      ])
    }
    def new() do
      %Rocks{ index: 0 }
    end
    def next(rocks) do
      pattern = elem(@patterns, rocks.index)
      rocks = %{ rocks | index: rem(rocks.index + 1, tuple_size(@patterns)) }
      { pattern, rocks }
    end
  end
  defmodule Jets do
    defstruct [:dirs, :index]
    def new(pattern) do
      dirs = for char <- String.codepoints(pattern) do
        case char do
          "<" -> -1
          ">" -> 1
        end
      end
      %Jets { dirs: List.to_tuple(dirs), index: 0 }
    end
    def next(jets) do
      dir = elem(jets.dirs, jets.index)
      jets = %Jets{ jets | index: rem(jets.index + 1, tuple_size(jets.dirs) ) }
      { dir, jets }
    end
  end

  defmodule Screen do
    @blank_row 0

    defstruct [:rows, :jets, :rocks]
    def new(pattern) do
      %Screen{
        rows: [],
        jets: Jets.new(pattern),
        rocks: Rocks.new(),
      }
    end

    def print(screen), do: print_rows(screen.rows)
    defp print_rows(rows) do
      for row <- rows do
        chars = for index <- 6..0 do
          cell = (row &&& Integer.pow(2, index)) != 0
          if cell, do: "#", else: "."
        end
        IO.puts("|#{chars}|")
      end
      IO.puts("+-------+")
    end

    def cycle_indexes(screen) do
      { screen.jets.index, screen.rocks.index }
    end
    def height(screen), do: length(screen.rows)

    def next(screen) do
      { dropping, rocks } = Rocks.next(screen.rocks)
      blank_rows = Stream.duplicate(0, length(dropping) + 3) |> Enum.to_list()
      rows = blank_rows ++ screen.rows
      { rows, jets } = do_drop(dropping, rows, screen.jets)
      rows = Enum.drop_while(rows, fn row -> row == @blank_row end)
      %Screen { rows: rows, jets: jets, rocks: rocks }
    end
    defp do_drop(dropping, rows, jets) do
      { hdir, jets } = Jets.next(jets)
      new_dropping = hshift(dropping, hdir)
      dropping = if overlapping(new_dropping, rows) do
        dropping
      else
        new_dropping
      end
      if overlapping(dropping, tl(rows)) do
        { merge(dropping, rows), jets }
      else
        [row_hd|row_tl] = rows
        { lower_rows, jets } = do_drop(dropping, row_tl, jets)
        { [row_hd|lower_rows], jets }
      end
    end

    defp hshift(dropping, -1) do
      if Enum.any?(dropping, fn row -> (row &&& 64) != 0 end) do
        dropping
      else
        for row <- dropping, do: (row <<< 1) &&& 127
      end
    end
    defp hshift(dropping, 1) do
      if Enum.any?(dropping, fn row -> (row &&& 1) != 0 end) do
        dropping
      else
        for row <- dropping, do: (row >>> 1)
      end
    end

    defp overlapping([], _), do: false
    defp overlapping(_, []), do: true
    defp overlapping([dropping|dropping_rows], [dropped|dropped_rows]) do
      (dropping &&& dropped) != 0
        or overlapping(dropping_rows, dropped_rows)
    end

    defp merge([], dropped), do: dropped
    defp merge([dropping|dropping_rows], [dropped|dropped_rows]) do
      merged = dropping ||| dropped
      [merged | merge(dropping_rows, dropped_rows)]
    end
  end

  def part1(input) do
    screen = Screen.new(input)
    states = Stream.iterate(screen, &Screen.next/1)
    final_state = Enum.at(states, 2022)
    Screen.height(final_state)
  end
  def part2(input) do
    target = 1000000000000
    screen = Screen.new(input)
    { first_cycle, drops_to_first_cycle } = find_first_cycle(screen)
    { next_cycle, drops_per_cycle } = find_next_cycle(first_cycle)
    height_per_cycle = Screen.height(next_cycle) - Screen.height(first_cycle)

    total_cycles = div(target - drops_to_first_cycle, drops_per_cycle)
    drops = drops_to_first_cycle + (total_cycles * drops_per_cycle)
    height = Screen.height(first_cycle) + (total_cycles * height_per_cycle)

    drops_to_end = target - drops
    final_state = Stream.iterate(first_cycle, &Screen.next/1) |> Enum.at(drops_to_end)
    height + Screen.height(final_state) - Screen.height(first_cycle)

#    states = Stream.iterate(screen, &Screen.next/1)
#    final_state = Enum.at(states, 1000000000000)
#    length(final_state.rows)
  end

  def find_first_cycle(screen) do
    screens = Stream.iterate({ screen, MapSet.new() }, fn { screen, seen } ->
      { Screen.next(screen), MapSet.put(seen, Screen.cycle_indexes(screen)) }
    end)
    { cycled, seen } = Enum.find(screens, fn { screen, seen } -> MapSet.member?(seen, Screen.cycle_indexes(screen)) end)
    { cycled, MapSet.size(seen) }
  end
  def find_next_cycle(screen) do
    screens = Stream.iterate({ Screen.next(screen), 1 }, fn { screen, count } ->
      { Screen.next(screen), count + 1}
    end)
    Enum.find(screens, fn { s, _ } -> Screen.cycle_indexes(screen) == Screen.cycle_indexes(s) end)
  end
end

input = File.read!("input")
IO.puts(Day17.part1(input))
IO.puts(Day17.part2(input))
