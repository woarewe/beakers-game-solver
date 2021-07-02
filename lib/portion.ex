defmodule Portion do
  @enforce_keys [:color]

  defstruct [:color]

  def match?(first, second) do
    first.color == second.color
  end
end
