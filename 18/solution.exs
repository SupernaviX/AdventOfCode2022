defmodule Day18 do
  def part1(input) do
    cubes = MapSet.new(input, &parse_cube/1)
    surface = surface_cubes(cubes)
    length(surface)
  end
  def part2(input) do
    cubes = MapSet.new(input, &parse_cube/1)
    surface = surface_cubes(cubes)
    outer_surface = meander(cubes)
    Enum.filter(surface, fn air -> MapSet.member?(outer_surface, air) end) |> length()
  end

  defp parse_cube(line) do
    [x, y, z] = String.split(line, ",") |> Enum.map(&String.to_integer/1)
    { x, y, z }
  end

  defp neighbors({ x, y, z }), do: Enum.filter([
    { x - 1, y, z },
    { x + 1, y, z },
    { x, y - 1, z },
    { x, y + 1, z },
    { x, y, z - 1 },
    { x, y, z + 1 }
  ], &in_bounds/1)
  defp in_bounds({ x, y, z }) do
    Enum.all?([x, y, z], fn coord -> coord in -2..25 end)
  end

  defp empty_neighbors(cube, cubes) do
    Enum.filter(neighbors(cube), fn neighbor -> !MapSet.member?(cubes, neighbor) end)
  end

  defp surface_cubes(cubes) do
    for cube <- cubes, neighbor <- empty_neighbors(cube, cubes) do
      neighbor
    end
  end

  defp meander(cubes) do
    frontier = :queue.new()
    seen = MapSet.new()
    meander(cubes, { frontier, seen }, { 1, 1, 1 })
  end
  defp meander(cubes, { frontier, seen }) do
    { next, frontier } = :queue.out(frontier)
    case next do
      { :value, air } -> meander(cubes, { frontier, seen }, air)
      :empty -> seen
    end
  end
  defp meander(cubes, { frontier, seen }, air) do
    if MapSet.member?(seen, air) do
      meander(cubes, { frontier, seen })
    else
      frontier = for neighbor <- empty_neighbors(air, cubes), reduce: frontier do
        f -> :queue.in(neighbor, f)
      end
      seen = MapSet.put(seen, air)
      meander(cubes, { frontier, seen })
    end
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day18.part1(input))
IO.puts(Day18.part2(input))
