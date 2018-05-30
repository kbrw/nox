defmodule Nox.Brunch do
  @moduledoc """
  brunch wrapper
  """
  use Nox.Bin, name: "brunch"

  @doc false
  def do_version(binpath) do
    with {semver, 0} <- System.cmd(binpath, ["--version"]) do
      String.trim(semver)
    else _ -> :error
    end
  end

  @doc """
  Install brunch in env
  """
  @spec make(Nox.Env.t) :: {:ok, warnings :: []} | {:error, term}
  def make(env) do
    if stale?(env) do
      Nox.Npm.install_global(env, "brunch")
    else
      {:ok, []}
    end
  end
end
