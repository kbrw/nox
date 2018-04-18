defmodule Nox.Nvm do
  @moduledoc """
  NVM wrapper
  """
  alias Nox.Semver

  @doc """
  Run NVM command
  """
  @spec run(Nox.Env.t, String.t | nil) :: :ok | {:error, code :: integer}
  def run(env, args) do
    exe = Path.join [basedir(env), "bin", "nodenv"]
    case System.cmd(exe, String.split(args), env: sys_env(env), stderr_to_stdout: true, into: Nox.Cli.stream()) do
      {_, 0} -> :ok
      {_, code} -> {:error, code}
    end
  end

  @doc """
  Returns environment variables for working with this env
  """
  @spec sys_env(Nox.Env.t) :: [{String.t, String.t}]
  def sys_env(env) do
    bindir = bindir(env)
    path0 = System.get_env("PATH")
    [
      {"PATH", "#{bindir}:#{path0}"},
      {"NODENV_ROOT", basedir(env)}
    ]
  end

  @doc false
  def basedir(env), do: Path.join env.dir, "nvm"

  @doc false
  def bindir(env), do: Path.join basedir(env), "shims"

  @doc """
  Returns true if installed version matches required one
  """
  @spec stale?(Nox.Env.t) :: boolean
  def stale?(env) do
    with out <- :os.cmd('git -C #{basedir(env)} describe 2> /dev/null'),
	 {_, _, _, _}=installed <- Semver.parse(String.trim("#{out}")) do
      Semver.cmp(env.versions.nvm, installed, :minor) > 0
    else _ -> false
    end
  end
end
