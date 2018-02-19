defmodule Nodex.Npm do
  @moduledoc """
  NPM wrapper
  """
  alias Nodex.Semver

  @doc """
  Returns npm version
  """
  @spec version() :: Semver.t | nil
  def version do
    with exe when exe != nil <- exe(),
	 {semver, 0} <- System.cmd(exe, ["--version"]) do
      Semver.parse(String.trim(semver))
    else _ -> :error
    end
  end

  defp exe, do: Nodex.which("npm")
end
