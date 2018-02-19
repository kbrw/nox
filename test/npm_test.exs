defmodule NpmTest do
  use ExUnit.Case

  test "npm install (ok)" do
    tmpdir = Path.join System.tmp_dir!(), "npm-test"
    File.mkdir_p!(tmpdir)

    File.cp!(Path.join(__DIR__, "package.json"), Path.join(tmpdir, "package.json"))
    assert match? :ok, Nodex.Npm.install(tmpdir)
    File.rm_rf!(tmpdir)
  end

  test "npm install (bad)" do
    tmpdir = Path.join System.tmp_dir!(), "npm-test"
    File.mkdir_p!(tmpdir)
    
    File.write!(Path.join(tmpdir, "package.json"), "JUST CRAP")
    assert match? {:error, _}, Nodex.Npm.install(tmpdir)
    File.rm_rf!(tmpdir)
  end
end
