defmodule Nox do
  @moduledoc """
  Wrappers for node and al. binaries
  """
  alias Nox.Nvm

  @doc """
  Returns full path to managed executable
  """
  @spec which(String.t) :: Path.t | nil
  def which(exe) do
    case System.cmd("which", [exe], env: [{"PATH", Nvm.bindir()}]) do
      {out, 0} -> String.trim(out)
      {_, 1} -> nil
    end
  end

  @doc """
  Returns env for running node related commands
  """
  @spec env() :: [{String.t, String.t}]
  def env, do: Nox.Nvm.env()
end