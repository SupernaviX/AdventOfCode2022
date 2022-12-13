defmodule Day10 do
  def part1(input) do
    special_states = execute(input)
      |> attach_cycle()
      |> Enum.drop(19)
      |> Enum.take_every(40)
    special_states |> Enum.map(&Tuple.product/1) |> Enum.sum()
  end

  def part2(input) do
    execute(input)
      |> Enum.with_index()
      |> Enum.map(&pixel/1)
      |> print()
  end

  defp execute(input) do
    [1 | Enum.flat_map(input, &parse_line/1)] |> Enum.scan(&run/2)
  end

  defp attach_cycle(states) do
    Enum.with_index(states) |> Enum.map(fn { reg, cycle } -> { reg, cycle + 1 } end)
  end

  defp pixel({ reg, cycle }) do
    cycle = Integer.mod(cycle, 40)
    if (abs(cycle - reg) < 2) do "#" else "." end
  end

  defp print(pixels) do
    pixels
      |> Enum.take(240)
      |> Enum.chunk_every(40)
      |> Enum.map(&Enum.join/1)
      |> Enum.join("\n")
  end

  defp parse_line("noop"), do: [:noop]
  defp parse_line("addx " <> num), do: [:noop, { :addx, String.to_integer(num) }]

  defp run(:noop, reg), do: reg
  defp run({ :addx, num }, reg), do: reg + num
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day10.part1(input))
IO.puts(Day10.part2(input))
