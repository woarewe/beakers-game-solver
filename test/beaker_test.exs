defmodule BeakerTest do
  use ExUnit.Case

  test "pouring over from empty" do
    first = %Beaker{capacity: 2, portions: []}
    second = %Beaker{capacity: 2, portions: []}
    assert {:error, _reason} = Beaker.pour_over(first, second)
  end

  test "pouring over to full" do
    first = %Beaker{
      capacity: 2,
      portions: [
        %Portion{color: "red", size: 1}
      ]
    }

    second = %Beaker{
      capacity: 2,
      portions: [
        %Portion{color: "red", size: 2}
      ]
    }
    assert {:error, _reason} = Beaker.pour_over(first, second)
  end

  test "pouring over to another color" do
    first = %Beaker{
      capacity: 2,
      portions: [
        %Portion{color: "red", size: 1}
      ]
    }

    second = %Beaker{
      capacity: 2,
      portions: [
        %Portion{color: "blue", size: 1}
      ]
    }
    assert {:error, _reason} = Beaker.pour_over(first, second)
  end

  test "pouring over" do
    first = %Beaker{
      capacity: 2,
      portions: [
        %Portion{color: "red", size: 1},
        %Portion{color: "blue", size: 1}
      ]
    }

    second = %Beaker{
      capacity: 2,
      portions: [
        %Portion{color: "red", size: 1}
      ]
    }
    assert {:ok, emptied_first, filled_second} = Beaker.pour_over(first, second)
    assert %Beaker{capacity: 2, portions: [%Portion{color: "blue", size: 1}]} = emptied_first
    assert %Beaker{capacity: 2, portions: [%Portion{color: "red", size: 2}]} = filled_second
  end

  test "pouring over with emptying the first" do
    first = %Beaker{
      capacity: 2,
      portions: [
        %Portion{color: "red", size: 1}
      ]
    }

    second = %Beaker{
      capacity: 2,
      portions: [
        %Portion{color: "red", size: 1}
      ]
    }
    assert {:ok, emptied_first, filled_second} = Beaker.pour_over(first, second)
    assert %Beaker{capacity: 2, portions: []} = emptied_first
    assert %Beaker{capacity: 2, portions: [%Portion{color: "red", size: 2}]} = filled_second
  end

  test "pouring over with splitting portions" do
    first = %Beaker{
      capacity: 3,
      portions: [
        %Portion{color: "red", size: 2}      ]
    }

    second = %Beaker{
      capacity: 3,
      portions: [
        %Portion{color: "red", size: 2}
      ]
    }
    assert {:ok, emptied_first, filled_second} = Beaker.pour_over(first, second)
    assert %Beaker{capacity: 3, portions: [%Portion{color: "red", size: 1}]} = emptied_first
    assert %Beaker{capacity: 3, portions: [%Portion{color: "red", size: 3}]} = filled_second
  end
end
