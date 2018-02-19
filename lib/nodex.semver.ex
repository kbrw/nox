defmodule Nodex.Semver do
  @moduledoc """
  Utils for semantic versions
  """
  @type t :: {number, number, number, String.t | nil}

  @doc """
  Parse string
  """
  @spec parse(String.t) :: t | :error
  def parse("v" <> str), do: do_parse(str)
  def parse(str), do: do_parse(str)

  @doc """
  Compare semantic versions:
  a == b -> 0
  a > b -> 1
  a < b -> -1

  If `until` is given, compares only until `until` level.

  ## Examples

      iex> Nodex.cmp("1.4.7beta0", "1.3.2")
      1

      iex> Nodex.cmp({1,4,7,"beta0"}, nil)
      1

      iex> Nodex.cmp({1,4,7,"beta0"}, {1,3,8,"beta1"})
      1

      iex> Nodex.cmp({1,4,7,"beta0"}, {1,3,8,"beta1"}, :major)
      0

      iex> Nodex.cmp({1,2,7,"beta0"}, {1,3,8,"beta1"}, :minor)
      -1
  """
  @spec cmp(a :: t | String.t, b :: t | String.t | any, until :: :major | :minor | :patch | :extra) :: -1 | 0 | 1
  def cmp(a, b, until \\ :extra)
  def cmp({_, _, _, _}=a, {_, _, _, _}=b, until) when until in [:major, :minor, :patch, :extra] do
    do_cmp(a, b, until, :major)
  end
  def cmp(a, b, until) when is_binary(a), do: cmp(parse(a), b, until)
  def cmp(a, b, until) when is_binary(b), do: cmp(a, parse(b), until)
  def cmp(_a, _b, _), do: 1

  ###
  ### Priv
  ###
  defp do_parse(nil), do: :error
  defp do_parse(str) do
    case String.split(str, ".", parts: 3) do
      [s1, s2] -> do_parse_int(s1, s2, "0")
      [s1, s2, s3] -> do_parse_int(s1, s2, s3)
      _ -> :error
    end
  end

  defp do_parse_int(s1, s2, s3) do
    with {major, ""} <- Integer.parse(s1),
	 {minor, ""} <- Integer.parse(s2),
	 {patch, extra} <- Integer.parse(s3) do
      {major, minor, patch, extra}
    else _ -> :error
    end
  end

  defp do_cmp({a, _, _, _},    {b, _, _, _},    _max,   :major) when a > b, do: 1
  defp do_cmp({a, _, _, _},    {b, _, _, _},    _max,   :major) when a < b, do: -1
  defp do_cmp({a, _, _, _},    {a, _, _, _},    :major, :major), do: 0
  defp do_cmp({a, _, _, _}=v1, {a, _, _, _}=v2, max,    :major), do: do_cmp(v1, v2, max, :minor)

  defp do_cmp({_, a, _, _},    {_, b, _, _},    _max,   :minor) when a > b, do: 1
  defp do_cmp({_, a, _, _},    {_, b, _, _},    _max,   :minor) when a < b, do: -1
  defp do_cmp({_, a, _, _},    {_, a, _, _},    :minor, :minor), do: 0
  defp do_cmp({_, a, _, _}=v1, {_, a, _, _}=v2, max,    :minor), do: do_cmp(v1, v2, max, :patch)
  
  defp do_cmp({_, _, a, _},    {_, _, b, _},    _max,   :patch) when a > b, do: 1
  defp do_cmp({_, _, a, _},    {_, _, b, _},    _max,   :patch) when a < b, do: -1
  defp do_cmp({_, _, a, _},    {_, _, a, _},    :patch, :patch), do: 0
  defp do_cmp({_, _, a, _}=v1, {_, _, a, _}=v2, max,    :patch), do: do_cmp(v1, v2, max, :extra)

  defp do_cmp({_, _, _, a},    {_, _, _, b}, _,         :extra) when a > b, do: -1
  defp do_cmp({_, _, _, a},    {_, _, _, b}, _,         :extra) when a < b, do: 1
  defp do_cmp({_, _, _, a},    {_, _, _, a}, _,         :extra), do: 0  
end
