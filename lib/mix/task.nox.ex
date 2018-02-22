defmodule Mix.Tasks.Nox.Install do
  @moduledoc "Install nvm, node and npm in priv dir"

  @nvm_git_url "https://github.com/nodenv/nodenv"
  @node_build_url "https://github.com/nodenv/node-build.git"

  require Logger

  alias Nox.Semver

  def run(args) do
    stale? = Semver.cmp(Mix.Project.config()[:versions][:nvm], Nox.Nvm.version(), :minor) > 0
    do_install_nvm(stale?, args)

    src = Path.join [Nox.Nvm.basedir(), "src", "realpath.c"]
    target = Path.join [Nox.Nvm.basedir(), "libexec", "nodenv-realpath.dylib"]
    do_compile_nvm(Mix.Utils.stale?([src], [target]))

    destdir = Path.join([Nox.Nvm.basedir(), "plugins", "node-build"])
    do_install_node_build(not File.exists?(destdir))

    stale? = Semver.cmp(Mix.Project.config()[:versions][:node], Nox.Node.version(), :minor) > 0
    do_install_node(stale?, args)

    _ = Nox.Nvm.run("global #{Mix.Project.config()[:versions][:node]}")
  end

  defp do_install_nvm(false, _args), do: Logger.info("SKIP nodenv.install (up-to-date)")
  defp do_install_nvm(true, args) do
    Mix.Tasks.Nox.Clean.run(args)

    nvm_vsn = Mix.Project.config()[:versions][:nvm]
    Logger.info("INSTALL nodenv #{nvm_vsn}")
    :ok = File.mkdir_p! Nox.Nvm.basedir()

    opts = [cd: Nox.Nvm.basedir(), stderr_to_stdout: true]    
    {_, 0} = System.cmd("git", ["init"], opts)
    {_, 0} = System.cmd("git", ["remote", "add", "-f", "origin", @nvm_git_url], opts)
    {_, 0} = System.cmd("git", ["checkout", nvm_vsn], opts)
  end

  defp do_compile_nvm(false), do: Logger.info("SKIP nodenv.compile (up-to-date)")
  defp do_compile_nvm(true) do
    Logger.info("COMPILE nodenv")

    configure = Path.join [Nox.Nvm.basedir(), "src", "configure"]
    srcdir = Path.join [Nox.Nvm.basedir(), "src"]
    {_, 0} = System.cmd(configure, [], cd: Nox.Nvm.basedir(), stderr_to_stdout: true, into: Nox.Cli.stream())
    {_, 0} = System.cmd("make", ["-C", srcdir], cd: Nox.Nvm.basedir(), stderr_to_stdout: true, into: Nox.Cli.stream())
  end

  defp do_install_node_build(false), do: Logger.info("SKIP node-build.install (up-to-date)")
  defp do_install_node_build(true) do
    Logger.info("INSTALL node-build")

    destdir = Path.join [Nox.Nvm.basedir(), "plugins", "node-build"]
    {_, 0} = System.cmd("git", ["clone", @node_build_url, destdir], stderr_to_stdout: true)    
  end

  defp do_install_node(false, _), do: Logger.info("SKIP node.install (up-to-date)")
  defp do_install_node(true, _args) do
    node_vsn = Mix.Project.config()[:versions][:node]
    
    Logger.info("INSTALL node #{node_vsn}")
    _ = Nox.Nvm.run("install #{node_vsn}")
  end
end

defmodule Mix.Tasks.Nox.Clean do
  @moduledoc "Cleanup nvm install"

  require Logger

  def run(_args) do
    Logger.info("CLEAN nvm")
    _ = File.rm_rf!(Nox.Nvm.basedir())
  end
end
