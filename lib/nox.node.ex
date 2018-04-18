defmodule Nox.Node do
  @moduledoc """
  node.js wrapper
  """
  alias Nox.Semver

  @doc """
  Returns false if installed version matches required one
  """
  @spec stale?(Nox.Env.t) :: boolean
  def stale?(env) do
    case version(env) do
      :error -> true
      vsn -> Semver.cmp(env.versions[:node], String.trim(vsn), :minor) != 0
    end
  end

  @doc """
  Returns real version from dir
  """
  @spec version(Nox.Env.t | Path.t) :: String.t | :error
  def version(dir) when is_binary(dir), do: version(Nox.Env.new(dir: dir))
  def version(env) do
    with node when node != nil <- exe(env),
	 {semver, 0} <- System.cmd(node, ["--version"]) do
      String.trim(semver)
    else _ -> :error
    end    
  end
  

  defp exe(env), do: Nox.which(env, "node")
end
