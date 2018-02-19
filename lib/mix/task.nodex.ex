defmodule Mix.Tasks.Nodex.Install do
  @moduledoc "Install nvm, node and npm in priv dir"

  @nvm_git_url "https://github.com/creationix/nvm"

  require Logger

  alias Nodex.Semver

  def run(args) do
    stale? = Semver.cmp(Mix.Project.config()[:versions][:nvm], Nodex.Nvm.version(), :minor) > 0
    do_install_nvm(stale?, args)

    stale? = Semver.cmp(Mix.Project.config()[:versions][:node], Nodex.Node.version(), :minor) > 0
    do_install_node(stale?, args)
  end

  defp do_install_nvm(false, _args), do: Logger.info("SKIP nvm.install (up-to-date)")
  defp do_install_nvm(true, args) do
    Mix.Tasks.Nodex.Clean.run(args)

    nvm_vsn = Mix.Project.config()[:versions][:nvm]
    Logger.info("INSTALL nvm #{nvm_vsn}")
    :ok = File.mkdir_p! Nodex.Nvm.basedir()

    opts = [cd: Nodex.Nvm.basedir(), stderr_to_stdout: true]    
    {_, 0} = System.cmd("git", ["init"], opts)
    {_, 0} = System.cmd("git", ["remote", "add", "-f", "origin", @nvm_git_url], opts)
    {_, 0} = System.cmd("git", ["checkout", nvm_vsn], opts)
  end

  defp do_install_node(false, _), do: Logger.info("SKIP node.install (up-to-date)")
  defp do_install_node(true, _args) do
    node_vsn = Mix.Project.config()[:versions][:node]
    
    Logger.info("INSTALL node #{node_vsn}")
    _ = Nodex.Nvm.run("install #{node_vsn}")
  end
end

defmodule Mix.Tasks.Nodex.Clean do
  @moduledoc "Cleanup nvm install"

  require Logger

  def run(_args) do
    Logger.info("CLEAN nvm")
    _ = File.rm_rf!(Nodex.Nvm.basedir())
  end
end
