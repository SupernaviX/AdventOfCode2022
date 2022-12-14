defmodule Day12 do
  defmodule Grid do
    defstruct [:width, :height, :start, :goals, :cells]

    def parse(input) do
      width = String.length(hd(input))
      height = length(input)
      cell_str = Enum.join(input)

      {start, _} = :binary.match(cell_str, "S")
      {goal, _} = :binary.match(cell_str, "E")
      cells = String.codepoints(cell_str)
        |> Enum.map(&parse_cell/1)
        |> List.to_tuple()

      %Grid{ width: width, height: height, start: start, goals: MapSet.new([goal]), cells: cells }
    end
    defp parse_cell("S"), do: 0
    defp parse_cell("E"), do: 25
    defp parse_cell(<<char::utf8>>), do: char - ?a

    def invert(grid) do
      %Grid{ width: width, height: height, cells: old_cells } = grid
      [start] = MapSet.to_list(grid.goals)
      cell_list = Tuple.to_list(old_cells) |> Enum.map(&(25 - &1))
      cells = List.to_tuple(cell_list)
      goals = Enum.with_index(cell_list)
        |> Enum.filter(fn { value, _ } -> value == 25 end)
        |> Enum.map(fn { _, idx } -> idx end)
        |> MapSet.new()
      %Grid{ width: width, height: height, start: start, goals: goals, cells: cells }
    end

    def start(grid) do
      idx_to_xy(grid, grid.start)
    end
    def is_goal(grid, { x, y }) do
      MapSet.member?(grid.goals, xy_to_idx(grid, { x, y }))
    end

    def successors(grid, { x, y }) do
      value = value_of(grid, { x, y })
      candidates = [
        { x - 1, y },
        { x + 1, y },
        { x, y - 1 },
        { x, y + 1 }
      ]
      Enum.filter(candidates, fn { x, y } ->
        x in 0..(grid.width - 1)
          and y in 0..(grid.height - 1)
          and value_of(grid, { x, y }) - value <= 1
      end)
    end

    def value_of(grid, { x, y }) do
      elem(grid.cells, xy_to_idx(grid, { x, y }))
    end

    defp xy_to_idx(grid, { x, y }) do
      x + (y * grid.width)
    end
    defp idx_to_xy(grid, idx) do
      { rem(idx, grid.width), div(idx, grid.width) }
    end
  end

  def part1(input) do
    grid = Grid.parse(input)
    path = bfs(grid)
    length(path)
  end
  def part2(input) do
    grid = Grid.invert(Grid.parse(input))
    path = bfs(grid)
    length(path)
  end

  defp bfs(grid) do
    bfs(grid, { Grid.start(grid), [] }, { :queue.new, MapSet.new() })
  end
  defp bfs(grid, { candidate, path }, { frontier, seen }) do
    cond do
      Grid.is_goal(grid, candidate) -> path
      MapSet.member?(seen, candidate) -> bfs(grid, { frontier, seen })
      true ->
        seen = MapSet.put(seen, candidate)
        successors = Grid.successors(grid, candidate)
        frontier = Enum.reduce(successors, frontier, fn (succ, queue) ->
          next = { succ, [ candidate | path] }
          :queue.in(next, queue)
        end)
        bfs(grid, { frontier, seen })
    end
  end
  defp bfs(grid, { frontier, seen }) do
    { { :value, next }, frontier } = :queue.out(frontier)
    bfs(grid, next, { frontier, seen })
  end

end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day12.part1(input))
IO.puts(Day12.part2(input))
