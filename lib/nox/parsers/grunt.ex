defmodule Nox.Parsers.Grunt do
  @moduledoc """
  Parser for Grunt
  """
  use Nox.Parser
  
  require Logger

  defstruct errors: [], warnings: []

  def init(_), do: %__MODULE__{}

  def parse("", s), do: s
  def parse("WARNING  " <> msg, s), do: warning(msg, s)
  def parse("Warning: " <> msg, s), do: warning(msg, s)
  def parse("ERROR " <> msg, s), do: error(msg, s)
  def parse(line, s), do: (Logger.info(String.trim(line)); s)

  def terminate(%__MODULE__{ warnings: warnings, errors: errors }=s) do
    %{ s | warnings: Enum.reverse(warnings), errors: Enum.reverse(errors) }
  end

  ###
  ### Priv
  ###
  defp warning(msg, %__MODULE__{ warnings: warnings }=s) do
    Logger.warn(msg)
    %{ s | warnings: [ msg | warnings ]}
  end

  defp error(msg, %__MODULE__{ errors: errors }=s) do
    Logger.error(msg)
    %{ s | errors: [ msg | errors ]}
  end
end
