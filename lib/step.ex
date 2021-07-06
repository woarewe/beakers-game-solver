defmodule Step do
  defstruct [:table,  :outs, history: []]

  def build_from_beakers(beakers) do
    table = Enum.with_index(beakers) |> Enum.reduce(%{}, fn({beaker, index}, map) ->
      Map.put(map, index + 1, beaker)
    end)
    %__MODULE__{table: table}
  end

  def outs(%__MODULE__{table: table} = step) do
    combinations = for from <- Map.keys(table), to <- Map.keys(table) do
      {from ,to}
    end
    outs = Enum.filter combinations, fn({from, to}) -> from != to end
    %__MODULE__{step | outs: outs}
  end

  def next_steps(%__MODULE__{table: table, outs: outs, history: history}) do
    Enum.reduce outs, [], fn({from, to}, new_outs) ->
      source = Map.get(table, from)
      destination = Map.get(table, to)
      case Beaker.pour_over(source, destination) do
        {:ok, emptied_source, filled_destination} ->
          updated_table = table
          |> Map.put(from, emptied_source)
          |> Map.put(to, filled_destination)

        new_outs ++ [%__MODULE__{
          history: history ++ [{from, to}],
          table: updated_table
        }]
        
        {:error, _reason} -> new_outs
      end
    end
  end

  def win?(%__MODULE__{table: table}) do
    Map.values(table) |> Enum.all?(&Beaker.complete?/1)
  end
end
