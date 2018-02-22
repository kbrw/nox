defmodule Nodex.Parsers.Logger do
  @moduledoc """
  Default CLI parser.
  Output lines with Logger.info
  """
  use Nodex.Parser

  require Logger

  @doc """
  Level can be :info, :debug, :warn
  """
  def init(level), do: level

  @doc false
  def parse(line, :info),  do: (Logger.info(line); :info)
  def parse(line, :debug), do: (Logger.debug(line); :debug)
  def parse(line, :warn),  do: (Logger.debug(line); :warn)
end
