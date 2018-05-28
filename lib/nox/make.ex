defmodule Nox.Make do
  @moduledoc """
  Functions for building node environment
  """
  require Logger

  alias Nox.Utils

  @nvm_git_url "https://github.com/nodenv/nodenv"
  @node_build_url "https://github.com/nodenv/node-build.git"
	
  @doc """
  Build a nodeJS environment with nvm node and npm
  """
  @spec all(Nox.Env.t) :: :ok | :noop | {:ok | :noop | :error, [Mix.Task.Compiler.Diagnostic.t()]}
  def all(env) do
    do_install_nvm(env, Nox.Nvm.stale?(env))

    src = Path.join [Nox.Nvm.basedir(env), "src", "realpath.c"]
    target = Path.join [Nox.Nvm.basedir(env), "libexec", "nodenv-realpath.dylib"]
    do_compile_nvm(env, Utils.stale?([src], [target]))

    destdir = Path.join([Nox.Nvm.basedir(env), "plugins", "node-build"])
    do_install_node_build(env, not File.exists?(destdir))

    do_install_node(env, Nox.Node.stale?(env))

    _ = Nox.Nvm.run(env, "global #{env.versions[:node]}")

    :ok
  end

  @doc """
  Cleanup node installation
  """
  @spec clean(Nox.Env.t) :: :ok | :noop | :error
  def clean(env) do
    Logger.info("CLEAN nvm")
    case File.rm_rf!(env.dir) do
      {:ok, []} -> :noop
      {:ok, _} -> :ok
      _ -> :error
    end
  end
  
  ###
  ### Priv
  ###
  defp do_install_nvm(_env, false), do: Logger.info("SKIP nodenv.install (up-to-date)")
  defp do_install_nvm(env, true) do
    _ = clean(env)

    Logger.info("INSTALL nodenv #{env.versions[:nvm]}")
    :ok = File.mkdir_p! Nox.Nvm.basedir(env)

    opts = [cd: Nox.Nvm.basedir(env), stderr_to_stdout: true]    
    {_, 0} = System.cmd("git", ["init"], opts)
    {_, 0} = System.cmd("git", ["remote", "add", "-f", "origin", @nvm_git_url], opts)
    {_, 0} = System.cmd("git", ["checkout", env.versions[:nvm]], opts)
  end

  defp do_compile_nvm(_env, false), do: Logger.info("SKIP nodenv.compile (up-to-date)")
  defp do_compile_nvm(env, true) do
    Logger.info("COMPILE nodenv")

    configure = Path.join [Nox.Nvm.basedir(env), "src", "configure"]
    srcdir = Path.join [Nox.Nvm.basedir(env), "src"]
    {_, 0} = System.cmd(configure, [], cd: Nox.Nvm.basedir(env), stderr_to_stdout: true, into: Nox.Cli.stream())
    {_, 0} = System.cmd("make", ["-C", srcdir], cd: Nox.Nvm.basedir(env), stderr_to_stdout: true, into: Nox.Cli.stream())
  end

  defp do_install_node_build(_env, false), do: Logger.info("SKIP node-build.install (up-to-date)")
  defp do_install_node_build(env, true) do
    Logger.info("INSTALL node-build")

    destdir = Path.join [Nox.Nvm.basedir(env), "plugins", "node-build"]
    {_, 0} = System.cmd("git", ["clone", @node_build_url, destdir], stderr_to_stdout: true)    
  end

  defp do_install_node(_env, false), do: Logger.info("SKIP node.install (up-to-date)")
  defp do_install_node(env, true) do
    Logger.info("INSTALL node #{env.versions[:node]}")
    _ = Nox.Nvm.run(env, "install #{env.versions[:node]}")
  end
end
