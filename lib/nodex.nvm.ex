defmodule Nodex.Nvm do
  @moduledoc """
  NVM wrapper
  """

  @nvm_env "NVM_DIR= NVM_CD_FLAGS= NVM_IOJS_ORG_MIRROR= NVM_PATH= NVM_RC_VERSION= NVM_BIN= NVM_NODEJS_ORG_MIRROR= "

  alias Nodex.Semver

  @doc """
  Run NVM command
  """
  @spec run(String.t) :: charlist
  def run(args) do
    if File.exists?(Path.join(basedir(), "nvm.sh")) do
      :os.cmd('#{@nvm_env} NVM_DIR=#{basedir()} . #{basedir()}/nvm.sh && nvm #{args}')
    else
      :ok
    end
  end

  @doc false
  def env do
    bindir = bindir()
    [
      {"NVM_DIR", basedir()},
      {"NVM_CD_FLAGS", ""},
      {"NVM_BIN", bindir},
      {"PATH", bindir}
    ]
  end

  @doc false
  def basedir, do: Path.join :code.priv_dir(:nodex), "nvm"

  @doc false
  def bindir do
    case Path.wildcard("#{basedir()}/versions/node/*/bin") do
      [] -> nil
      [ bindir ] -> bindir
    end
  end

  @doc """
  Returns installed nvm version
  """
  def version do
    with {:ok, data} <- File.read(Path.join(basedir(), "package.json")),
	 {:ok, json} <- Poison.decode(data),
	 {_, _, _, _}=semver <- Semver.parse(json["version"]) do
      semver
    else _ -> :error
    end
  end
end
