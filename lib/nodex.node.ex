defmodule Nodex.Node do
  @moduledoc """
  node.js wrapper
  """
  alias Nodex.Semver

  @doc """
  Returns node version
  """
  @spec version() :: Semver.t | nil
  def version do
    with node when node != nil <- exe(),
	 {semver, 0} <- System.cmd(node, ["--version"]) do
      Semver.parse(String.trim(semver))
    else _ -> :error
    end
  end

  defp exe, do: Nodex.which("node")
end
