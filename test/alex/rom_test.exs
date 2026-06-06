defmodule Alex.ROMTest do
  use Alex.Case, async: true

  alias Alex.ROM

  test "resolve/2 returns an existing path as-is" do
    path = tetris_rom()
    assert {:ok, ^path} = ROM.resolve(path)
  end

  test "resolve/2 finds a ROM by name in a given rom_dir" do
    dir = Path.dirname(tetris_rom())
    assert {:ok, resolved} = ROM.resolve("tetris", rom_dir: dir)
    assert resolved == tetris_rom()
  end

  test "resolve/2 errors for unknown names" do
    dir = Path.dirname(tetris_rom())
    assert {:error, reason} = ROM.resolve("nope", rom_dir: dir)
    assert reason =~ "could not find ROM"
  end

  test "resolve!/2 raises for unknown names" do
    dir = Path.dirname(tetris_rom())
    assert_raise ArgumentError, fn -> ROM.resolve!("nope", rom_dir: dir) end
  end

  test "list/1 includes the bundled tetris fixture" do
    dir = Path.dirname(tetris_rom())
    assert "tetris" in ROM.list(rom_dir: dir)
  end
end
