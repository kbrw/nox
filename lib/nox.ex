defmodule Nox do
  @moduledoc """
  Wrappers for node and al. binaries
  """
  alias Nox.Nvm

  @doc """
  Returns full path to managed executable
  """
  @spec which(Nox.Env.t, String.t) :: Path.t | nil
  def which(env, exe) do
    case System.cmd("which", [exe], env: [{"PATH", Nvm.bindir(env)}]) do
      {out, 0} -> String.trim(out)
      {_, 1} -> nil
    end
  end

  @doc """
  Returns environment variables (OS) for running node related commands
  """
  @spec sys_env(Nox.Env.t) :: [{String.t, String.t}]
  def sys_env(env), do: Nox.Nvm.sys_env(env)
end
