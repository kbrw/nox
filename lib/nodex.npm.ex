defmodule Nodex.Npm do
  @moduledoc """
  NPM wrapper
  """
  alias Nodex.Semver
  alias Nodex.Parsers.Npm, as: Parser

  @doc """
  Launch npm install in the given dir
  """
  @spec install(Path.t) :: :ok | {:error, errors :: [String.t]}
  def install(dir) do
    stream = Nodex.Cli.stream({Parser, false})
    case System.cmd("npm", ["install"], cd: dir, into: stream, env: Nodex.Nvm.env(), stderr_to_stdout: true) do
      {%Parser{}, 0} -> :ok
      {%Parser{ errors: errors }, 1} -> {:error, errors}
    end
  end

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
