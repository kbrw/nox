defmodule Nox.Utils do
  @moduledoc """
  Utilities functions

  Stolen from Mix, to avoid dependancies between Mix and application at runtime
  """
  require Record
  
  require Logger

  Record.defrecord :file_info, Record.extract(:file_info, from_lib: "kernel/include/file.hrl")

  @doc """
  Returns `true` if any of the `sources` are stale
  compared to the given `targets`.
  """
  @spec stale?([Path.t], [Path.t]) :: boolean
  def stale?(sources, targets) do
    Enum.any?(stale_stream(sources, targets))
  end

  @doc """
  Returns the date the given path was last modified in posix time.

  If the path does not exist, it returns the Unix epoch
  (1970-01-01 00:00:00).
  """
  @spec last_modified(Path.t) :: integer
  def last_modified(path)

  def last_modified(timestamp) when is_integer(timestamp) do
    timestamp
  end

  def last_modified(path) do
    case :file.read_file_info(path, [:raw, {:time, :posix}]) do
      {:ok, file_info(mtime: mtime)} -> mtime
      {:error, _} -> 0
    end
  end

  ###
  ### Priv
  ###
  defp stale_stream(sources, targets) do
    modified_target = targets |> Enum.map(&last_modified/1) |> Enum.min()

    Stream.filter(sources, fn source ->
      last_modified(source) > modified_target
    end)
  end
end
