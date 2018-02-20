defmodule Nodex.Parsers.Npm do
  @moduledoc """
  Parser for NPM
  """
  use Nodex.Parser
  
  require Logger

  defstruct errors: [], warnings: []

  def init(_), do: %__MODULE__{}

  def parse("", s), do: s
  def parse("npm WARN " <> msg, %__MODULE__{ warnings: warnings }=s) do
    Logger.warn(msg)
    %{ s | warnings: [ msg | warnings ]}
  end
  def parse("npm ERR! " <> msg, %__MODULE__{ errors: errors }=s) do
    Logger.error(msg)
    %{ s | errors: [ msg | errors ]}
  end
  def parse(line, s), do: (Logger.info(String.trim(line)); s)

  def terminate(%__MODULE__{ warnings: warnings, errors: errors }=s) do
    %{ s | warnings: Enum.reverse(warnings), errors: Enum.reverse(errors) }
  end
end
