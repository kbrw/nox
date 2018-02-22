defmodule Nodex.Cli.Stream do
  require Logger

  alias Nodex.Cli

  defstruct acc: "", parser: nil

  def into(<< ?\n, rest :: binary >>, %{ acc: "" }=stream), do: into(rest, stream)
  def into(<< ?\n, rest :: binary >>, %{ acc: acc, parser: nil }=stream) do
    Logger.info(acc)
    into(rest, %{ stream | acc: "" })
  end
  def into(<< ?\n, rest :: binary >>, %{ acc: acc, parser: {mod, state0} }=stream) do
    try do
      state = mod.parse(acc, state0)
      into(rest, %{ stream | acc: "", parser: {mod, state} })
    rescue _ ->
	into(rest, %{ stream | acc: "" })
    end
  end
  def into("", stream), do: stream
  def into(<< c :: utf8, rest :: binary >>, %Cli.Stream{ acc: acc }=stream) do
    into(rest, %{ stream | acc: << acc :: binary, c :: utf8 >> })
  end

  defimpl Collectable do
    def into(%Cli.Stream{}=stream0) do
      collector = fn
	stream, {:cont, data} -> Cli.Stream.into(data, stream)
	%Cli.Stream{ parser: {parser, parser_state} }, :done -> parser.terminate(parser_state)
	_acc, :halt -> :ok
      end
      {stream0, collector}
    end
  end
end
