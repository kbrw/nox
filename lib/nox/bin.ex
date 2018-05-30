defmodule Nox.Bin do
  @moduledoc """
  bin wrapper functions
  """

  @callback do_version(binpath :: Path.t) :: String.t

  @doc """
  Generates following functions:

  * `stale?/1`
  * `version/1`
  * `which/1`
  """
  defmacro __using__(opts) do
    name = Keyword.get_lazy(opts, :name, fn -> raise "Missing keyword: :name" end)
    quote do
      @behaviour Nox.Bin
      @bin :"#{unquote(name)}"

      alias Nox.Semver

      @doc """
      Return false if actual version is the required one
      """
      @spec stale?(Nox.Env.t) :: boolean
      def stale?(env) do
	case version(env) do
	  semver when is_binary(semver) ->
	    Semver.cmp(env.versions[@bin], semver, :minor) != 0
	  _ -> true
	end
      end

      @doc """
      Get actual version
      """
      @spec version(dir :: Path.t | env :: Nox.Env.t) :: String.t
      def version(dir) when is_binary(dir), do: version(Nox.Env.new(dir: dir))
      def version(%Nox.Env{}=env) do
	case which(env) do
	  nil -> :error
	  path -> do_version(path)
	end
      end

      @doc """
      Returns full path to bin
      """
      @spec which(Nox.Env.t) :: Path.t
      def which(env), do: Nox.which(env, "#{@bin}")
    end
  end
end
