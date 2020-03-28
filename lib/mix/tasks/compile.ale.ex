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
