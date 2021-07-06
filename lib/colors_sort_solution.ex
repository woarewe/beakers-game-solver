defmodule ColorsSortSolution do
  def init do
    {:ok, %{"capacity" => capacity, "beakers" => colors_list}} = Path.join(File.cwd!(), "example.yml") |> YamlElixir.read_from_file
    beakers = for colors <- colors_list do
      portions = Enum.map colors, fn(%{"color" => color, "size" => size}) -> %Portion{color: color, size: size} end
      %Beaker{capacity: capacity, portions: portions}
    end
   [Step.build_from_beakers(beakers)]
  end
  
  def run([head | tail], step_hashes \\ %{}) do
    if Step.win?(head) do
      head.history
    else
      steps = head
      |> Step.outs()
      |> Step.next_steps()
      |> filter_dups(step_hashes)

      step_hashes = Enum.reduce steps, step_hashes, fn(step, hashes) ->
        Map.put(hashes, :erlang.phash2(step.table), step.table)
      end

      run(tail ++ steps, step_hashes)
    end
  end

  defp filter_dups(steps, step_hashes) do
    Enum.filter steps, fn(step) -> !Map.has_key?(step_hashes, :erlang.phash2(step.table)) end
  end
end
