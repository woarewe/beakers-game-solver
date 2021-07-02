defmodule Portion do
  @default_size 1
  @enforce_keys [:color, :size]

  defstruct [:color, :size]

  def build(color, size \\ @default_size) do
    %__MODULE__{color: color, size: size}
  end

  def same_color?(first, second) do
    get_color(first) == get_color(second)
  end

  def merge(first, second) do
    if same_color?(first, second) do
      %__MODULE__{color: get_color(first), size: get_size(first) + get_size(second)}
    else
      {:error, :different_color}
    end  
  end
  
  def separate(%__MODULE__{color: color, size: size}, new_size) do
    if new_size >= size do
      {:error, :impossible}
    else
      {:ok, build(color, new_size), build(color, size - new_size)}
    end
  end

  def get_color(%__MODULE__{color: color}) do 
    color
  end

  def get_size(%__MODULE__{size: size}) do 
    size
  end
end
