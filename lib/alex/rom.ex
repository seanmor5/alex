defmodule Alex.ROM do
  @moduledoc """
  Convenience functions for finding, verifying, and loading ROMs.
  """

  @supported_roms %{
    "b0e1ee07fbc73493eac5651a52f90f00" => "tetris.bin"
  }

  def check_rom_exists(path_to_rom) do
    if File.exists?(path_to_rom) do
      :ok
    else
      {:error, "Could not find ROM File: `#{path_to_rom}`."}
    end
  end

  def check_rom_supported(path_to_rom) do
    hash =
      path_to_rom
      |> File.stream!()
      |> Enum.reduce(
        :crypto.hash_init(:md5),
        fn chunk, prev ->
          :crypto.hash_update(prev, chunk)
        end
      )
      |> :crypto.hash_final()
      |> Base.encode16()
      |> String.downcase()

    if Map.has_key?(@supported_roms, hash) do
      :ok
    else
      {:error, "Unsupported ROM: `#{path_to_rom}`."}
    end
  end
end
