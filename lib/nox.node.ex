defmodule Nox.Node do
  @moduledoc """
  node.js wrapper
  """
  use Nox.Bin, name: "node"

  @doc false
  def do_version(binpath) do
    case System.cmd(binpath, ["--version"]) do
      {semver, 0} -> String.trim(semver)
      _ -> :error
    end
  end

  @doc """
  Eval a javascript code in given env
  """
  @spec eval(Nox.Env.t, String.t) :: {:ok, String.t} | :error
  def eval(env, code) do
    case System.cmd(which(env), ["-p", code]) do
      {out, 0} -> {:ok, out}
      _ -> :error
    end
  end
end
