defmodule Mix.Tasks.Compile.Nox do
  @moduledoc """
  Install nvm, node and npm in priv dir
  """
  require Logger

  @doc false
  def run(_args) do
    Nox.Make.all(Nox.Env.default())
  end

  @doc false
  def clean() do
    Nox.Make.clean(Nox.Env.default())
  end
end
