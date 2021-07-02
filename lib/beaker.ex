defmodule Beaker do
  @default_capacity 4
  defstruct [capacity: @default_capacity, portions: []]

  def build(capacity \\ @default_capacity) do
    %__MODULE__{capacity: capacity}
  end

  def pour_in(%__MODULE__{portions: portions} = beaker, new_portion)  do
    top = top_portion(beaker)
    if can_be_filled?(beaker) and (!top || Portion.match?(top, new_portion))do
      {:ok, %__MODULE__{beaker | portions: [new_portion | portions]}}
    else
      {:error, :impossible}
    end
  end

  def pour_out(%__MODULE__{portions: portions} = beaker) do
    if empty?(beaker) do
      {:error, :empty}
    else
      [portion | tail] = portions
      {:ok, portion, %__MODULE__{portions: tail}}
    end
  end

  def available_portions(%__MODULE__{capacity: capacity, portions: portions}) do
    capacity - length(portions)
  end

  def can_be_filled?(beaker) do
    available_portions(beaker) > 0
  end

  def empty?(%__MODULE__{portions: portions}) do
    length(portions) == 0
  end

  def top_portion(%__MODULE__{portions: portions}) do
    List.first(portions)
  end

  def pour_over(first, second) do
    case pour_out(first) do
      {:ok, portion, new_first} ->
        case pour_in(second, portion) do
          {:ok, new_second} -> {:ok, new_first, new_second}
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end
end
