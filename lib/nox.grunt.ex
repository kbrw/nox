defmodule Nox.Grunt do
  @moduledoc """
  Grunt wrapper
  """
  use Nox.Bin, name: "grunt"
  
  alias Nox.Parsers.Grunt, as: Parser

  @typedoc "Options used by the `run` function"
  @type opts :: [opt]

  @typedoc "Option values specific to the `run` function"
  @type opt ::
          {:force, boolean}

  @doc """
  Run grunt in the given dir
  """
  @spec run(Nox.Env.t, Path.t, opts) :: {:ok, warnings :: [String.t] | :uptodate} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def run(env, dir, opts \\ []) do
    args = if Keyword.get(opts, :force, false), do: ["--force"], else: []
    stream = Nox.Cli.stream({Parser, []})
    
    case System.cmd("grunt", args, cd: dir, into: stream, env: Nox.Nvm.sys_env(env), stderr_to_stdout: true) do
      {%Parser{ warnings: warnings }, 0} -> {:ok, warnings}
      {%Parser{ warnings: warnings, errors: errors }, code} ->
	{:error, {code, warnings, errors}}
    end
  end

  ###
  ### Nox.Bin callback
  ###
  @doc false
  def do_version(binpath) do
    case System.cmd(binpath, ["--version"]) do
      {"grunt-cli " <> semver, 0} -> String.trim(semver)
      _ -> :error
    end
  end
end
