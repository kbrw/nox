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
end
