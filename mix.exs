defmodule Mix.Tasks.Compile.Ale do
  use Mix.Task.Compiler

  def run(_args) do
    cwd = File.cwd!()
    path_to_ale_build = Path.join([Path.dirname(__ENV__.file), "src", "ale", "build"])

    IO.write("Compiling ALE. This will take some time.\n")

    if File.exists?(path_to_ale_build) do
      IO.write("ALE Already Compiled.\n")
    else
      with :ok          <- File.mkdir(path_to_ale_build),
           :ok          <- File.cd(path_to_ale_build),
           {_result, 0} <- System.cmd("cmake", ["-DUSE_SDL=ON", ".."], stderr_to_stdout: true),
           {_result, 0} <- System.cmd("make", ["-j", "4"], stderr_to_stdout: true),
           :ok          <- File.cd(cwd) do
        IO.write("Successfully compiled ALE.\n")
        :ok
      else
        {result, err} ->
          IO.write("#{err}: #{result}\n")
          :error
      end
    end
  end
end

defmodule Alex.MixProject do
  use Mix.Project

  @version "0.3.1"
  @url "https://www.github.com/seanmor5/alex"
  @maintainers ["Sean Moriarity"]

  def project do
    [
      name: "ALEx",
      app: :alex,
      version: @version,
      elixir: "~> 1.9",
      compilers: [:ale, :yecc, :leex, :erlang, :elixir, :app],
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      source_url: @url,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
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
      ]
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
    []
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
      files: ~w(lib priv/tetris.bin .formatter.exs mix.exs README* src/ale/src
                src/ale_nif.cpp src/nifpp.h src/ale/ale.cfg src/ale/makefile.mac src/ale/makefile.unix
                src/ale/CMakeLists.txt src/ale/common.rules),
      links: %{"GitHub" => "http://www.github.com/seanmor5/alex"},
      licenses: ["GNU General Public License 2.0"]
    ]
  end
end
