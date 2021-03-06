defmodule NpmTest do
  use ExUnit.Case

  test "npm install (ok)" do
    env = Nox.Env.default()
    
    tmpdir = Path.join System.tmp_dir!(), "npm-test"
    File.mkdir_p!(tmpdir)

    File.cp!(Path.join(__DIR__, "package.json"), Path.join(tmpdir, "package.json"))
    assert match? {:ok, _}, Nox.Npm.install(env, tmpdir)
    File.rm_rf!(tmpdir)
  end

  test "npm install (bad)" do
    env = Nox.Env.default()
    
    tmpdir = Path.join System.tmp_dir!(), "npm-test"
    File.mkdir_p!(tmpdir)
    
    File.write!(Path.join(tmpdir, "package.json"), "JUST CRAP")
    assert match? {:error, _}, Nox.Npm.install(env, tmpdir)
    File.rm_rf!(tmpdir)
  end
end
