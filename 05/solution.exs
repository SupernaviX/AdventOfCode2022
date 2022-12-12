defmodule Day5 do
  def part1(input) do
    { stacks, instructions } = parse(input)
    final_stacks = Enum.reduce(instructions, stacks, &execute_p1/2)
    top_of_stacks(final_stacks)
  end

  def part2(input) do
    { stacks, instructions } = parse(input)
    final_stacks = Enum.reduce(instructions, stacks, &execute_p2/2)
    top_of_stacks(final_stacks)
  end

  defp parse(input) do
    # lol one line
    {box_lines, [labels | [_ | instrs]]} = Enum.split_while(input, &(!String.starts_with?(&1, " 1")))
    stacks = parse_stacks(box_lines, labels)
    instructions = Enum.map(instrs, &parse_instruction/1)
    { stacks, instructions }
  end

  defp execute_p1({ count, from, to }, stacks) when count > 0 do
    [item | from_stack] = elem(stacks, from)
    to_stack = [item | elem(stacks, to)]
    new_stacks = stacks
        |> put_elem(from, from_stack)
        |> put_elem(to, to_stack)
    execute_p1({ count - 1, from, to }, new_stacks)
  end
  defp execute_p1({ 0, _, _ }, stacks) do stacks end

  defp execute_p2({ count, from, to }, stacks) do
    { items, from_stack } = Enum.split(elem(stacks, from), count)
    to_stack = items ++ elem(stacks, to)
    stacks
      |> put_elem(from, from_stack)
      |> put_elem(to, to_stack)
  end

  defp top_of_stacks(stacks) do
    Tuple.to_list(stacks)
      |> Enum.map(&List.first/1)
  end

  defp parse_stacks(box_lines, labels) do
    count = count_stacks(labels)
    box_lines
      |> Enum.map(&(parse_box_line(&1, count)))
      |> transpose()
      |> Enum.map(fn stack -> Enum.drop_while(stack, &(&1 == " ")) end)
      |> List.to_tuple()
  end

  @instr_regex ~r/move (\d+)+ from (\d+) to (\d+)/
  defp parse_instruction(instr) do
    [move, from, to] = Regex.run(@instr_regex, instr)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
    { move, from - 1, to - 1 }
  end

  defp count_stacks(labels) do
    String.trim(labels)
      |> String.split(" ", trim: true)
      |> List.last()
      |> String.to_integer()
  end

  defp parse_box_line(box_line, count) do
    String.codepoints(box_line)
      |> Enum.drop(1)
      |> Enum.take_every(4)
      |> Enum.take(count)
  end

  defp transpose(lines) do
    lines
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
  end
end

input = File.stream!("input")
IO.puts(Day5.part1(input))
IO.puts(Day5.part2(input))
