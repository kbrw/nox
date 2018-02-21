defmodule Nodex.Nvm do
  @moduledoc """
  NVM wrapper
  """
  alias Nodex.Semver

  @doc """
  Run NVM command
  """
  @spec run(String.t) :: :ok | {:error, code :: integer}
  def run(args) do
    case System.cmd("nodenv", String.split(args), env: env(), stderr_to_stdout: true, into: Nodex.Cli.stream()) do
      {_, 0} -> :ok
      {_, code} -> {:error, code}
    end
  end

  @doc false
  def env do
    bindir = Path.join basedir(), "bin"
    shimsdir = bindir()
    path0 = System.get_env("PATH")
    [
      {"PATH", "#{shimsdir}:#{bindir}:#{path0}"},
      {"NODENV_ROOT", basedir()}
    ]
  end

  @doc false
  def basedir, do: Path.join :code.priv_dir(:nodex), "nvm"

  @doc false
  def bindir, do: Path.join basedir(), "shims"

  @doc """
  Returns installed nvm version
  """
  def version do
    with out <- :os.cmd('git -C #{basedir()} describe 2> /dev/null'),
	 {_, _, _, _}=semver <- Semver.parse(String.trim("#{out}")) do
      semver
    else _ -> :error
    end
  end
end
