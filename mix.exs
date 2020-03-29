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

  def project do
    [
      app: :alex,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
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
end
