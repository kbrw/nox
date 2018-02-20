defmodule Nodex.Npm do
  @moduledoc """
  NPM wrapper
  """
  alias Nodex.Semver
  alias Nodex.Parsers.Npm, as: Parser

  @typedoc "Options used by the `install` function"
  @type install_opts :: [install_opt]

  @typedoc "Option values used by the `install` function"
  @type install_opt ::
          {:werror, boolean}
  
  @doc """
  Launch npm install in the given dir
  """
  @spec install(Path.t, install_opts) :: {:ok, warnings :: [String.t]} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def install(dir, opts \\ []) when is_list(opts) do
    werror = Keyword.get(opts, :werror, false)
    
    stream = Nodex.Cli.stream({Parser, []})
    {parser, code} = System.cmd("npm", ["install"], cd: dir, into: stream, env: Nodex.Nvm.env(), stderr_to_stdout: true)
    finalize(code, parser, werror)
  end

  @doc """
  Returns npm version
  """
  @spec version() :: Semver.t | nil
  def version do
    with exe when exe != nil <- exe(),
	 {semver, 0} <- System.cmd(exe, ["--version"]) do
      Semver.parse(String.trim(semver))
    else _ -> :error
    end
  end

  @doc """
  Returns full path to npm executable
  """
  def exe, do: Nodex.which("npm")

  ###
  ### Priv
  ###
  defp finalize(0, %Parser{ warnings: [], errors: [] }, true), do: {:ok, []}
  defp finalize(0, %Parser{ warnings: warnings, errors: [] }, false), do: {:ok, warnings}
  defp finalize(code, parser, _), do: {:error, {code, parser.warnings, parser.errors}}
end
