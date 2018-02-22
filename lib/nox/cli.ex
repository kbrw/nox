defmodule Nodex.Cli do
  @moduledoc """
  Utilities for playing with commands output
  """
  alias Nodex.Parsers
  alias Nodex.Cli

  @doc """
  Returns a command-line stream collector, using given parser to parse output.
  Default parser is Nodex.Parsers.Logger
  """
  @spec stream(parser :: {module, any}) :: %Cli.Stream{}
  def stream(parser_and_args \\ {Parsers.Logger, :info})
  def stream({parser, args}) do
    parser_state = parser.init(args)
    %Cli.Stream{ parser: {parser, parser_state} }
  end
  def stream(args), do: stream({Parsers.Logger, args})
end
