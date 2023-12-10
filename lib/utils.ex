defmodule Interpolation.Utils do
  def log_unexpected_message(message) do
    IO.inspect(
      pid: self(),
      error: "Unexpected message",
      message: message
    )
  end

  def register_process(name, pid) do
    Process.link(pid)
    Process.register(pid, name)
  end

  def float_range(first, last, step) do
    Stream.iterate(first, &(&1 + step))
    |> Stream.take_while(fn x -> x <= last end)
    |> Enum.to_list()
  end

  def push_point(points, point, window) when length(points) < window do
    points ++ [point]
  end

  def push_point(points, point, _) do
    tl(points) ++ [point]
  end
end
