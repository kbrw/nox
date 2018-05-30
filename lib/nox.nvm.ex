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
  def bindir(env) do
    [bindir] = Path.wildcard(Path.join([basedir(env), "versions", "*", "bin"]))
    bindir
  end

  @doc """
  Returns true if installed version matches required one
  """
  @spec stale?(Nox.Env.t) :: boolean
  def stale?(env) do
    case version(env) do
      :error -> true
      vsn -> Semver.cmp(env.versions[:nvm], vsn, :minor) != 0
    end
  end

  @doc """
  Returns real version from dir
  """
  @spec version(Path.t | Nox.Env.t) :: String.t
  def version(dir) when is_binary(dir), do: version(Nox.Env.new(dir: dir))
  def version(env) do
    out = :os.cmd('git -C #{basedir(env)} describe 2> /dev/null')
    case String.trim("#{out}") do
      "" -> :error
      vsn -> vsn
    end
  end
end
