defmodule Day7 do
  defmodule Dir do
    defstruct size: 0, child_dirs: []

    def add_file(dir, size) do
      %Dir{dir | size: dir.size + size}
    end

    def add_child_dir(dir, child_dir) do
      new_child_dirs = [child_dir | dir.child_dirs]
      %Dir{dir | child_dirs: new_child_dirs}
    end
  end

  defmodule State do
    defstruct cwd: [], dirs: %{}

    def cd_root(state) do
      %State{state | cwd: []}
    end
    def cd_up(state) do
      new_cwd = Enum.drop(state.cwd, 1)
      %State{state | cwd: new_cwd }
    end
    def cd_down(state, dir) do
      new_cwd = [dir | state.cwd]
      %State{state | cwd: new_cwd }
    end

    def ls_spotted_dir(state, dir) do
      update_current_dir(state, &(Dir.add_child_dir(&1, dir)))
    end

    def ls_spotted_file(state, size) do
      update_current_dir(state, &(Dir.add_file(&1, size)))
    end

    def dir_sizes(state) do
      Map.keys(state.dirs) |> Enum.map(&(dir_size(state, &1)))
    end

    def total_size(state) do
      dir_size(state, [])
    end

    defp dir_size(state, dir_name) do
      dir = state.dirs[dir_name]
      dir.size + Enum.sum(Enum.map(dir.child_dirs, fn child ->
        child_name = [child | dir_name]
        dir_size(state, child_name)
      end))
    end

    defp update_current_dir(state, update) do
      current_dir = Map.get(state.dirs, state.cwd, %Dir{})
      new_current_dir = update.(current_dir)
      put_in(state.dirs[state.cwd], new_current_dir)
    end
  end

  def part1(input) do
    state = parse(input, %State{})
    State.dir_sizes(state)
      |> Enum.filter(&(&1 <= 100000))
      |> Enum.sum()
  end

  def part2(input) do
    state = parse(input, %State{})
    unused_space = 70_000_000 - State.total_size(state)
    min_dir_size = 30_000_000 - unused_space
    State.dir_sizes(state)
      |> Enum.sort()
      |> Enum.find(&(&1 > min_dir_size))
  end

  defp parse(["$ cd /" | rest], state) do
    parse(rest, State.cd_root(state))
  end
  defp parse(["$ cd .." | rest], state) do
    parse(rest, State.cd_up(state))
  end
  defp parse(["$ cd " <> dir | rest], state) do
    parse(rest, State.cd_down(state, dir))
  end
  defp parse(["$ ls" | rest], state) do
    parse_ls(rest, state)
  end
  defp parse([], state), do: state

  defp parse_ls(input = ["$" <> _ | _], state) do
    parse(input, state)
  end
  defp parse_ls(["dir " <> dir | rest], state) do
    parse_ls(rest, State.ls_spotted_dir(state, dir))
  end
  defp parse_ls([file | rest], state) do
    [raw_filesize|_] = String.split(file, " ")
    filesize = String.to_integer(raw_filesize)
    parse_ls(rest, State.ls_spotted_file(state, filesize))
  end
  defp parse_ls([], state), do: state
end

input = File.stream!("input") |> Enum.map(&String.trim/1)
IO.puts(Day7.part1(input))
IO.puts(Day7.part2(input))
