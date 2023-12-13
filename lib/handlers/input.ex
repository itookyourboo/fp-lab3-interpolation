defmodule Interpolation.Handler.Input do
  def start(listeners) do
    spawn(fn -> loop(listeners) end)
  end

  defp loop(listeners) do
    line = IO.gets("")
    process_line(line, listeners)

    if line != :eof do
      loop(listeners)
    end
  end

  defp process_line(:eof, listeners) do
    Enum.each(listeners, fn pid ->
      send(pid, {:stop, nil, self()})
    end)
  end

  defp process_line(line, listeners) do
    point = line_to_point(line)

    Enum.each(listeners, fn pid ->
      send(pid, {:new_point, point, self()})
    end)
  end

  defp line_to_point(line) do
    line
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&Float.parse/1)
    |> Enum.map(&elem(&1, 0))
  end
end
