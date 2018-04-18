defmodule Nox.Node do
  @moduledoc """
  node.js wrapper
  """
  alias Nox.Semver

  @doc """
  Returns true if installed version matches required one
  """
  @spec stale?(Nox.Env.t) :: boolean
  def stale?(env) do
    with node when node != nil <- exe(env),
	 {semver, 0} <- System.cmd(node, ["--version"]) do
      Semver.cmp(env.versions.node, String.trim(semver), :minor) > 0      
    else _ -> false
    end
  end

  defp exe(env), do: Nox.which(env, "node")
end
