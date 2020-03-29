defmodule Mix.Tasks.Compile.Ale do
  use Mix.Task

  def run(_args) do
    {:ok, cwd} = File.cwd()
    path_to_ale = Path.join([cwd, "csrc", "ale", "build"])

    if File.exists?(path_to_ale) do
      IO.write("ALE Already Compiled.\n")
    else
      with {_result, 0} <- System.cmd("mkdir", [path_to_ale]),
           :ok <- File.cd(path_to_ale),
           {_result, 0} <- System.cmd("cmake", ["-DUSE_SDL=ON", ".."]),
           {result, 0} <- System.cmd("make", ["-j", "4"]) do
        IO.write("#{result}")
      else
        {result, err_code} ->
          IO.write("Compiling ALE returned #{result}\nError Code: #{err_code}.\n")
      end
    end
  end
end

defmodule Alex.MixProject do
  use Mix.Project

  @version "0.1.1"
  @url "https://www.github.com/seanmor5/alex"
  @maintainers ["Sean Moriarity"]

  def project do
    [
      name: "ALEx",
      app: :alex,
      version: @version,
      elixir: "~> 1.10",
      package: package(),
      source_url: @url,
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      maintainers: @maintainers,
      homepage_url: @url,
      description: description(),
      docs: docs(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      compilers: [:ale] ++ Mix.compilers()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def docs do
    [
      source_ref: "v#{@version}",
      main: "getting-started",
      extra_section: "guides",
      formatters: ["html", "epub"],
      groups_for_modules: groups_for_modules(),
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "guides/getting-started.md",
      "guides/installation.md",
      "guides/configuration.md",
      "guides/supported-roms.md"
    ]
  end

  defp groups_for_extras do
    []
  end

  defp groups_for_modules do
    []
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp description do
    "ALEx lets you run the Arcade Learning Environment from Elixir."
  end

  defp package do
    [
      maintainers: @maintainers,
      name: "alex",
      files: ["lib/**/*.ex", "mix*", "csrc/ale/src", "priv", "README*", "csrc/ale/CMakeLists.txt", "csrc/ale/common.rules", "csrc/ale/makefile.mac", "csrc/ale/makefile.unix", "csrc/ale_nif.cpp", "csrc/nifpp.h"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "http://www.github.com/seanmor5/alex"}
    ]
  end
end
