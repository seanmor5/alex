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

  @version "0.1.0"
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

  def docs do
    [
      source_ref: "v#{@version}",
      extra_section: "guides",
      formatters: ["html", "epub"],
      groups_for_modules: groups_for_modules(),
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "guides/installation.md",
      "guides/getting-started.md",
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
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "http://www.github.com/seanmor5/alex"}
    ]
  end
end
