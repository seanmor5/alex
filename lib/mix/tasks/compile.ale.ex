defmodule Mix.Tasks.Compile.Ale do
  use Mix.Task

  def run(_args) do
    path_to_ale = Path.join(["src", "ale", "build"])

    if File.exists?(path_to_ale) do
      IO.write("ALE Already Compiled.\n")
    else
      IO.write("Compiling ALE. This will take some time.\n")
      with {_result, 0} <- System.cmd("mkdir", [path_to_ale], stderr_to_stdout: true),
           :ok <- File.cd(path_to_ale),
           {_result, 0} <- System.cmd("cmake", ["-DUSE_SDL=ON", ".."], stderr_to_stdout: true),
           {result, 0} <- System.cmd("make", ["-j", "4"], stderr_to_stdout: true) do
        IO.binwrite result
        if Version.match?(System.version(), "~> 1.9"), do: {:ok, []}, else: :ok
      else
        {result, err_code} ->
          IO.binwrite result
          {:error, result, err_code}
      end
    end
  end
end
