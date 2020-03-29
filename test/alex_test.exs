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

    test "step/2" do
      interface = Alex.new()
      interface = Alex.load(interface, "priv/tetris.bin")
      assert %Interface{frame: 1, episode_frame: 1} = Alex.step(interface, 2)
    end

    test "set_option/3" do
      interface = Alex.new()
      assert %Interface{display_screen: true} = Alex.set_option(interface, :display_screen, true)
      assert %Interface{display_screen: true} = Alex.set_option(interface, "display_screen", true)
      assert %Interface{random_seed: 123} = Alex.set_option(interface, :random_seed, 123)
    end

    test "set_state/2" do
      interface = Alex.new()
      interface = Alex.load(interface, "priv/tetris.bin")
      state1 = interface.state
      interface = Alex.step(interface, 1)
      state2 = interface.state
      interface = Alex.set_state(interface, state1)
      assert state1.encoded == interface.state.encoded
      interface = Alex.set_state(interface, state2)
      assert state2.encoded == interface.state.encoded
    end

    test "game_over?/1" do
      interface = Alex.new()
      interface = Alex.load(interface, "priv/tetris.bin")
      assert Alex.game_over?(interface) == false
    end

    test "reset/1" do
      interface = Alex.load(Alex.new(), "priv/tetris.bin")
      interface = Alex.step(interface, 1)
      assert %Interface{episode_frame: 0} = Alex.reset(interface)
    end
  end
end
