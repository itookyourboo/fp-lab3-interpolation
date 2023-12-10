defmodule Interpolation.Utils.Test do
  use ExUnit.Case
  alias Interpolation.Utils

  @window 3

  test "push_point/3 Empty window" do
    assert Utils.push_point([], [1, 2], @window) == [[1, 2]]
  end

  test "push_point/3 Window with one element" do
    assert Utils.push_point([[1, 2]], [2, 3], @window) == [[1, 2], [2, 3]]
  end

  test "push_point/3 Window overflow" do
    assert Utils.push_point([[1, 2], [2, 3], [3, 4]], [4, 5], @window) == [[2, 3], [3, 4], [4, 5]]
  end

  test "float_range/3 Final element should not exceed last" do
    assert almost_equal?(
             Utils.float_range(1, 2, 0.4),
             [1.0, 1.4, 1.8]
           )
  end

  test "float_range/3 Include last" do
    assert almost_equal?(
             Utils.float_range(1, 2, 0.2),
             [1.0, 1.2, 1.4, 1.6, 1.8, 2.0]
           )
  end

  defp almost_equal?(list1, list2) when length(list1) != length(list2), do: false

  defp almost_equal?(list1, list2) do
    Enum.zip(list1, list2)
    |> Enum.all?(fn {x, y} -> abs(x - y) < 0.000001 end)
  end
end
