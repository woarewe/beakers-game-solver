defmodule Beaker do
  @default_capacity 4
  defstruct [capacity: @default_capacity, portions: []]

  def build(capacity \\ @default_capacity, portions \\ []) do
    %__MODULE__{capacity: capacity, portions: portions}
  end

  def complete?(%__MODULE__{portions: portions, capacity: capacity}) do
    case portions do
      [portion] -> Portion.get_size(portion) == capacity
      [] -> true
      _ -> false
    end
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

  def pour_out(%__MODULE__{portions: portions} = beaker, required_size) do
    case portions do
      [%{size: size} = portion | tail] ->
        cond do
          required_size > size -> {:error, :empty}
          required_size == size -> {:ok, portion, %__MODULE__{beaker | portions: tail}}
          required_size < size ->
            {:ok, required_portion, left_portion} = Portion.separate(portion, required_size)
            {
              :ok,
              required_portion,
              %__MODULE__{beaker | portions: [left_portion | tail]}
            }
        end
      [] -> {:error, :empty}
    end
  end

  def pour_out(%__MODULE__{portions: portions} = beaker) do
    case portions do
      [%{size: size} = _portion | _tail] ->
        pour_out(beaker, size)
      [] -> {:error, :empty}
    end
  end

  def last_portion(%__MODULE__{portions: portions}) do
    List.last(portions)
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
      case last_portion(first) do
        nil -> {:error, :empty}
        portion ->
          portion_size = Portion.get_size(portion)
          if available_volume >= portion_size do
            case pour_out(first, portion_size) do
              {:ok, portion, emptied_first} -> 
                case pour_in(second, portion) do
                  {:ok, filled_second} -> {:ok, emptied_first, filled_second}
                  {:error, reason} -> {:error, reason}
                end
              {:error, reason} -> {:error, reason}
            end
          else
            {:ok, portion_for_second, emptied_first} = Beaker.pour_out(first, available_volume)
            case pour_in(second, portion_for_second) do
              {:ok, filled_second} -> {:ok, emptied_first, filled_second}
              {:error, reason} -> {:error, reason}
            end
          end
      end
    else
      {:error, :not_enough_volume}
    end
  end
end
