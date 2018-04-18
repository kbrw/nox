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
  @spec compile(Nox.Env.t, Path.t, compile_opts) :: {:ok, warnings :: [String.t] | :uptodate} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def compile(env, dir, opts \\ []) do
    force = Keyword.get(opts, :force, false)
    if force or Mix.Utils.stale?([Path.join(dir, "package.json")], [node_path(dir)]) do
      install(env, dir, opts)
    else
      {:ok, :uptodate}
    end
  end
  
  @doc """
  Launch npm install
  """
  @spec install(Nox.Env.t, Path.t, install_opts | Path.t, install_opts) :: {:ok, warnings :: [String.t]} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def install(env, dir) when is_binary(dir), do: do_install(env, dir, ["install"], [])
  def install(env, dir, opts) when is_binary(dir) and is_list(opts), do: do_install(env, dir, ["install"], opts)
  def install(env, dir, archive) when is_binary(dir) and is_binary(archive), do: install(env, dir, archive, [])
  def install(env, dir, archive, opts) when is_binary(dir) and is_binary(archive) and is_list(opts) do
    args = ["install"]
    args = if Keyword.get(opts, :no_save, false) do
      args ++ ["--no-save"]
    else
      args
    end
    do_install(env, dir, args ++ [archive], opts)
  end

  @doc """
  Install global
  """
  @spec install_global(Nox.Env.t, String.t, install_opts) :: {:ok, warnings :: [String.t]} | {:error, {code :: number, warnings :: [String.t],  errors :: [String.t]}}
  def install_global(env, name, opts \\ []) when is_binary(name) and is_list(opts) do
    do_install(env, File.cwd!(), ["install", "-g", name], opts)
  end

  @doc """
  Clean up application 
  """
  @spec clean(Nox.Env.t, Path.t) :: :ok
  def clean(_, dir) do
    Logger.info("CLEAN #{dir}")
    File.rm_rf!(node_path(dir))
  end

  @doc """
  Returns true if installed version matches required one
  """
  @spec stale?(Nox.Env.t) :: boolean
  def stale?(env) do
    with exe when exe != nil <- exe(env),
	 {semver, 0} <- System.cmd(exe, ["--version"]) do
      Semver.cmp(env.versions.npm, String.trim(semver), :minor) > 0
    else _ -> false
    end
  end

  @doc """
  Returns full path to npm executable
  """
  def exe(env), do: Nox.which("npm", env)

  @doc """
  Return NODE_PATH for given project
  """
  def node_path(dir), do: Path.join(dir, "node_modules")
  
  ###
  ### Priv
  ###
  defp do_install(env, dir, args, opts) do
    werror = Keyword.get(opts, :werror, false)
    stream = Nox.Cli.stream({Parser, []})
    npm_exe = Nox.which(env, "npm")
    {parser, code} = System.cmd(npm_exe, args, cd: dir, into: stream, env: sys_env(dir, dir), stderr_to_stdout: true)
    do_finalize(code, parser, werror)
  end
  
  defp sys_env(env, dir), do: [
    {"NODE_PATH", node_path(dir)}
  ] ++ Nox.Nvm.sys_env(env)

  defp do_finalize(0, %Parser{ warnings: [], errors: [] }, true), do: {:ok, []}
  defp do_finalize(0, %Parser{ warnings: warnings, errors: [] }, false), do: {:ok, warnings}
  defp do_finalize(code, parser, _), do: {:error, {code, parser.warnings, parser.errors}}
end
