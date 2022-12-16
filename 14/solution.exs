defmodule Day14 do
  defmodule Cave do
    defstruct [:cells, :columns, :floor]

    def parse(input) do
      cells = Enum.reduce(input, MapSet.new(), &parse_path/2)
      %Cave { cells: cells, columns: cells_to_columns(cells) }
    end

    def add_floor(cave) do
      floor = Enum.max(Enum.map(cave.cells, fn { _ , y } -> y end)) + 2
      %Cave { cave | floor: floor }
    end

    def drop(cave), do: drop({ 500, 0 }, cave)
    defp drop({ x, y }, cave) do
      new_y = find_ground({ x, y }, cave)
      cond do
        is_nil(new_y) -> :donezo
        new_y < 0 -> :donezo
        is_empty({ x - 1, new_y + 1 }, cave) ->
          drop({ x - 1, new_y + 1 }, cave)
        is_empty({ x + 1, new_y + 1 }, cave) ->
          drop({ x + 1, new_y + 1 }, cave)
        true -> { :moar, fill_cell({ x, new_y }, cave ) }
      end
    end

    defp find_ground({ x, y }, cave) do
      column = Map.get(cave.columns, x, [])
      ground = Enum.drop_while(column, &(&1 < y))
      case ground do
        [below|_] -> below - 1
        [] -> if is_nil(cave.floor), do: nil, else: cave.floor - 1
      end
    end

    defp is_empty({ x, y }, cave) do
      not MapSet.member?(cave.cells, { x, y })
        and (is_nil(cave.floor) or y < cave.floor)
    end

    defp fill_cell({ x, y }, cave) do
      cells = MapSet.put(cave.cells, { x, y })
      columns = Map.update(cave.columns, x, [y], fn ys -> Enum.sort([y | ys]) end)
      %Cave{ cave | cells: cells, columns: columns }
    end

    defp parse_path(line, full) do
      String.split(line, " -> ")
        |> Enum.map(&parse_point/1)
        |> fill_in_lines(full)
    end
    defp parse_point(point) do
      [x, y] = String.split(point, ",") |> Enum.map(&String.to_integer/1)
      { x, y }
    end
    defp fill_in_lines(points, full) do
      segments = Enum.zip(points, tl(points))
      Enum.reduce(segments, full, &fill_in_line/2)
    end
    defp fill_in_line({{ x, y }, { x, y }}, full) do
      MapSet.put(full, { x, y })
    end
    defp fill_in_line({{ x1, y }, { x2, y }}, full) do
      full = MapSet.put(full, { x1, y })
      nextx1 = if x1 < x2 do x1 + 1 else x1 - 1 end
      fill_in_line({{ nextx1, y }, { x2, y }}, full)
    end
    defp fill_in_line({{ x, y1 }, { x, y2 }}, full) do
      full = MapSet.put(full, { x, y1 })
      nexty1 = if y1 < y2 do y1 + 1 else y1 - 1 end
      fill_in_line({{ x, nexty1 }, { x, y2 }}, full)
    end

    defp cells_to_columns(cells) do
      Enum.group_by(cells, fn { x, _ } -> x end, fn { _, y } -> y end)
        |> Enum.map(fn { x, ys } -> { x, Enum.sort(ys) } end)
        |> Map.new()
    end
  end

  def part1(input) do
    cave = Cave.parse(input)
    solve(cave)
  end
  def part2(input) do
    cave = Cave.add_floor(Cave.parse(input))
    solve(cave)
  end

  defp solve(cave), do: solve(cave, 0)
  defp solve(cave, drops) do
    case Cave.drop(cave) do
      { :moar, cave } -> solve(cave, drops + 1)
      :donezo -> drops
    end
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day14.part1(input))
IO.puts(Day14.part2(input))
