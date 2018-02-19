defmodule Nodex.Cli.Stream do
  require Logger

  alias Nodex.Cli

  defstruct acc: "", parser: nil
  
  def get_line(<< ?\n, rest :: binary >>, %{ acc: acc }=stream), do: {:ok, acc, %{ stream | acc: rest }}
  def get_line("", stream), do: {:more, stream}
  def get_line(<< c :: utf8, rest :: binary >>, %Cli.Stream{ acc: acc }=stream) do
    get_line(rest, %{ stream | acc: << acc :: binary, c :: utf8 >> })
  end

  defimpl Collectable do
    def into(%Cli.Stream{}=stream0) do
      collector = fn
	stream, {:cont, data} ->
	  case Cli.Stream.get_line(data, stream) do
	    {:ok, line, %Cli.Stream{ parser: nil }=stream} ->
	      Logger.info(line)
	      stream
	    {:ok, line, %Cli.Stream{ parser: {parser, parser_state0} }=stream} ->
	      try do
		parser_state = parser.parse(line, parser_state0)
		%{ stream | parser: {parser, parser_state} }
	      rescue _ ->
		  stream
	      end
	    {:more, stream} -> stream
	  end
	%Cli.Stream{ parser: {parser, parser_state} }, :done ->
	  parser.terminate(parser_state)
	_acc, :halt ->
	  :ok
      end
      {stream0, collector}
    end
  end
end
