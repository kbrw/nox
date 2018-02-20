defmodule Nodex.Grunt do
  @moduledoc """
  Grunt wrapper
  """
  alias Nodex.Parsers.Grunt, as: Parser

  @typedoc "Options used by the `run` function"
  @type opts :: [opt]

  @typedoc "Option values specific to the `run` function"
  @type opt ::
          {:force, boolean}

  @doc """
  Run grunt in the given dir
  """
  @spec run(Path.t, opts) :: {:ok, warnings :: [String.t] | :uptodate} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def run(dir, opts \\ []) do
    args = if Keyword.get(opts, :force, false), do: ["--force"], else: []
    stream = Nodex.Cli.stream({Parser, []})
    
    case System.cmd("grunt", args, cd: dir, into: stream, env: Nodex.Nvm.env(), stderr_to_stdout: true) do
      {%Parser{ warnings: warnings }, 0} -> {:ok, warnings}
      {%Parser{ warnings: warnings, errors: errors }, code} ->
	{:error, {code, warnings, errors}}
    end
  end
end
