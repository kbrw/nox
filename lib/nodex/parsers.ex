defmodule Nodex.Parser do
  @moduledoc """
  Defines Cli Parser behaviour
  """

  @doc false
  @callback init(args :: term) :: any

  @doc false
  @callback parse(line :: binary, state) :: state  when state: any

  @doc false
  @callback terminate(state :: any) :: any

  defmacro __using__(_args) do
    quote do
      @behaviour Nodex.Parser

      @doc false
      def terminate(state) do
	state
      end

      defoverridable terminate: 1
    end
  end
end
