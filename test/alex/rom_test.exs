defmodule ROMTest do
  import Alex.ROM
  use ExUnit.Case

  describe "rom" do
    test "rom_exists?/1" do
      path_to_rom = "priv/tetris.bin"
      assert :ok = rom_exists?(path_to_rom)
      assert {:error, err} = rom_exists?("bad")
    end

    test "rom_supported?/1" do
      path_to_rom = "priv/tetris.bin"
      assert :ok = rom_supported?(path_to_rom)
      assert {:error, err} = rom_supported?("priv/unsupported.bin")
    end
  end
end