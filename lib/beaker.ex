defmodule Beaker do
  @default_capacity 4
  defstruct [capacity: @default_capacity, portions: []]

  def build(capacity \\ @default_capacity, portions \\ []) do
    %__MODULE__{capacity: capacity, portions: portions}
  end

  def pour_in(beaker, portion) do
    if can_be_poured_in?(beaker, portion) do
      case pour_out(beaker) do
        {:error, :empty} -> {:ok, %__MODULE__{beaker | portions: [portion]}}
        {:ok, top_portion, %__MODULE__{portions: left_portions} = emptied_beaker} ->
           {:ok, %__MODULE__{emptied_beaker | portions: [Portion.merge(portion, top_portion) | left_portions]}}
      end
    else
      {:error, :impossible}
    end
  end

  def pour_out(%__MODULE__{portions: portions} = beaker) do
    if empty?(beaker) do
      {:error, :empty}
    else
      [portion | tail] = portions
      {:ok, portion, %__MODULE__{beaker | portions: tail}}
    end
  end

  def available_volume(%__MODULE__{capacity: capacity, portions: portions}) do
    capacity - Enum.reduce(portions, 0, fn p, sum -> Portion.get_size(p) + sum end)
  end

  def can_be_poured_in?(beaker, portion) do
    portion_size = Portion.get_size(portion)
    available_volume = Beaker.available_volume(beaker)
    match_by_color?(beaker, portion) && available_volume >= portion_size
  end

  def match_by_color?(beaker, portion) do
    top_portion = get_top_portion(beaker)
    empty?(beaker) or Portion.same_color?(top_portion, portion)
  end

  def empty?(%__MODULE__{portions: portions}) do
    length(portions) == 0
  end

  def get_top_portion(%__MODULE__{portions: portions}) do
    List.first(portions)
  end

  def pour_over(first, second) do
    available_volume = available_volume(second)

    if available_volume > 0 do
      case pour_out(first) do
        {:ok, portion, emptied_first} ->
          portion_size = Portion.get_size(portion)
          if available_volume >= portion_size do
            case pour_in(second, portion) do
              {:ok, filled_second} -> {:ok, emptied_first, filled_second}
              {:error, reason} -> {:error, reason}
            end
          else
            {:ok, portion_for_second, portion_for_first} = Portion.separate(portion, available_volume)
            case pour_in(second, portion_for_second) do
              {:ok, filled_second} ->
                {:ok, restored_first} = pour_in(emptied_first, portion_for_first)
                {:ok, restored_first, filled_second}
              {:error, reason} -> {:error, reason}
            end
          end
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :not_enough_volume}
    end
  end
end
