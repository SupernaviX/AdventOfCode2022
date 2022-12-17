defmodule Day15 do
  def part1(input) do
    sensors = parse(input)
    { ranges, beacons } = find_ranges_and_beacons_in_row(sensors, 2000000)
    range_sizes = Enum.map(ranges, &Range.size/1) |> Enum.sum()
    range_sizes - MapSet.size(beacons)
  end
  def part2(input) do
    sensors = parse(input)
    { x, y } = find_gap(sensors)
    x * 4000000 + y
  end

  defp parse(input), do: Enum.map(input, &parse_sensor/1)
  defp parse_sensor(line) do
    ["Sensor at " <> sensor, "closest beacon is at " <> beacon] = String.split(line, ": ")
    { parse_coords(sensor), parse_coords(beacon) }
  end
  defp parse_coords(coords) do
    ["x=" <> x, "y=" <> y] = String.split(coords, ", ")
    { String.to_integer(x), String.to_integer(y) }
  end

  defp find_ranges_and_beacons_in_row(sensors, row) do
    acc = { row, [], MapSet.new() }
    { _, ranges, beacons } = Enum.reduce(sensors, acc, &track_in_row/2)
    { ranges, beacons }
  end
  defp track_in_row({{ sx, sy }, { bx, by }}, { row, ranges, beacons }) do
    radius = abs(sx - bx) + abs(sy - by)
    distance_to_row = abs(sy - row)
    radius_in_row = radius - distance_to_row
    range = Range.new(sx - radius_in_row, sx + radius_in_row)

    ranges = if radius_in_row > 0, do: add_range(range, ranges), else: ranges
    beacons = if row == by, do: MapSet.put(beacons, bx), else: beacons

    { row, ranges, beacons }
  end
  defp add_range(range, []), do: [range]
  defp add_range(range, [nextrange | ranges]) do
    cond do
      range.last < nextrange.first ->
        [range, nextrange | ranges]
      nextrange.last < range.first ->
        [nextrange | add_range(range, ranges)]
      range.last in nextrange ->
        newfirst = min(range.first, nextrange.first)
        [Range.new(newfirst, nextrange.last) | ranges]
      nextrange.last in range ->
        newfirst = min(range.first, nextrange.first)
        add_range(Range.new(newfirst, range.last), ranges)
    end
  end

  defp find_gap(sensors), do: find_gap(sensors, 0)
  defp find_gap(_, 4000000), do: :whoops
  defp find_gap(sensors, row) do
    { ranges, beacons } = find_ranges_and_beacons_in_row(sensors, row)
    gap = find_gap_in_row(ranges, beacons)
    if is_nil(gap) do
      find_gap(sensors, row + 1)
    else
      { gap, row }
    end
  end

  defp find_gap_in_row([_], _), do: nil
  defp find_gap_in_row([range, nextrange | ranges], beacons) do
    candidate = range.last + 1
    if candidate == nextrange.first - 1 and not MapSet.member?(beacons, candidate) do
      candidate
    else
      find_gap_in_row([nextrange | ranges], beacons)
    end
  end
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day15.part1(input))
IO.puts(Day15.part2(input))
