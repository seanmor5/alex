defmodule Mix.Tasks.Compile.Ale do
  use Mix.Task

  def run(_args) do
    {:ok, cwd} = File.cwd()
    path_to_ale = Path.join([cwd, "csrc", "ale", "build"])
    :ok = if File.exists?(path_to_ale), do: delete_ale_build(), else: :ok
    with {result, 0} <- System.cmd("mkdir", [path_to_ale]),
         :ok         <- File.cd(path_to_ale),
         {result, 0} <- System.cmd("cmake", ["-DUSE_SDL=ON", ".."]),
         {result, 0} <- System.cmd("make", ["-j", "4"]) do
          IO.write("#{result}")
    else
      {result, err_code} -> IO.write("Compiling ALE returned #{result}\nError Code: #{err_code}.\n")
    end
  end

  defp delete_ale_build do
    {:ok, cwd} = File.cwd()
    path_to_ale = Path.join([cwd, "csrc", "ale", "build"])
    File.rm(path_to_ale)
  end
end