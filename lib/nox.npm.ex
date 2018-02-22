defmodule Nox.Npm do
  @moduledoc """
  NPM wrapper
  """
  require Logger
  
  alias Nox.Semver
  alias Nox.Parsers.Npm, as: Parser

  @typedoc "Options used by the `compile` function"
  @type compile_opts :: [compile_opt |install_opt]

  @typedoc "Option values specific to the `compile` function"
  @type compile_opt ::
          {:force, boolean}

  @typedoc "Options used by the `install` function"
  @type install_opts :: [install_opt]

  @typedoc "Option values used by the `install` function"
  @type install_opt ::
          {:werror, boolean}

  @doc """
  Launch npm install if `node_modules` is stale

  Can be forced with `force` opt
  """
  @spec compile(Path.t, compile_opts) :: {:ok, warnings :: [String.t] | :uptodate} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def compile(dir, opts \\ []) do
    force = Keyword.get(opts, :force, false)
    if force or Mix.Utils.stale?([Path.join(dir, "package.json")], [node_path(dir)]) do
      install(dir, opts)
    else
      {:ok, :uptodate}
    end
  end
  
  @doc """
  Launch npm install
  """
  @spec install(Path.t, install_opts | Path.t, install_opts) :: {:ok, warnings :: [String.t]} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def install(dir) when is_binary(dir), do: do_install(dir, ["install"], [])
  def install(dir, opts) when is_binary(dir) and is_list(opts), do: do_install(dir, ["install"], opts)
  def install(dir, archive) when is_binary(dir) and is_binary(archive), do: install(dir, archive, [])
  def install(dir, archive, opts) when is_binary(dir) and is_binary(archive) and is_list(opts) do
    args = ["install"]
    args = if Keyword.get(opts, :no_save, false) do
      args ++ ["--no-save"]
    else
      args
    end
    do_install(dir, args ++ [archive], opts)
  end

  @doc """
  Install global
  """
  @spec install_global(String.t, install_opts) :: {:ok, warnings :: [String.t]} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def install_global(name, opts \\ []) when is_binary(name) and is_list(opts) do
    do_install(File.cwd!(), ["install", "-g", name], opts)
  end

  @doc """
  Clean up application 
  """
  @spec clean(Path.t) :: :ok
  def clean(dir) do
    Logger.info("CLEAN #{dir}")
    File.rm_rf!(node_path(dir))
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
  def exe, do: Nox.which("npm")

  @doc """
  Return NODE_PATH for given project
  """
  def node_path(dir), do: Path.join(dir, "node_modules")
  
  ###
  ### Priv
  ###
  defp do_install(dir, args, opts) do
    werror = Keyword.get(opts, :werror, false)
    stream = Nox.Cli.stream({Parser, []})
    npm_exe = Nox.which("npm")
    {parser, code} = System.cmd(npm_exe, args, cd: dir, into: stream, env: env(dir), stderr_to_stdout: true)
    do_finalize(code, parser, werror)
  end
  
  defp env(dir), do: [
    {"NODE_PATH", node_path(dir)}
  ] ++ Nox.Nvm.env()

  defp do_finalize(0, %Parser{ warnings: [], errors: [] }, true), do: {:ok, []}
  defp do_finalize(0, %Parser{ warnings: warnings, errors: [] }, false), do: {:ok, warnings}
  defp do_finalize(code, parser, _), do: {:error, {code, parser.warnings, parser.errors}}
end
