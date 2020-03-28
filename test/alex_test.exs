defmodule AlexTest do
  alias Alex.Interface
  use ExUnit.Case
  doctest Alex

  describe "Alex" do
    test "new/0" do
      assert %Interface{} = Alex.new()
      assert %Interface{display_screen: true} = Alex.new(display_screen: true)
      assert %Interface{random_seed: 123} = Alex.new(random_seed: 123)
    end

    test "load/2" do
      tetris = "priv/tetris.bin"
      interface = Alex.new()

      assert_raise RuntimeError, "Unsupported ROM: `priv/unsupported.bin`.", fn ->
        Alex.load(interface, "priv/unsupported.bin")
      end

      assert_raise RuntimeError, "Could not find ROM File: `bad/path/rom`.", fn ->
        Alex.load(interface, "bad/path/rom")
      end

      assert %Interface{rom: tetris} = Alex.load(interface, tetris)
    end

    test "set_option/3" do
      interface = Alex.new()
      assert %Interface{display_screen: true} = Alex.set_option(interface, :display_screen, true)
      assert %Interface{display_screen: true} = Alex.set_option(interface, "display_screen", true)
    end
  end
end
