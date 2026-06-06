defmodule AlexTest do
  use Alex.Case, async: true

  alias Alex.Env

  describe "new/2" do
    test "loads a ROM by path and captures static metadata" do
      env = tetris_env()

      assert %Env{} = env
      assert env.rom =~ "tetris.bin"
      assert env.screen_dims == {210, 160}
      assert env.ram_size == 128
      assert length(env.legal_actions) == 18
      assert :noop in env.minimal_actions
      assert is_list(env.modes) and env.modes != []
      assert is_list(env.difficulties) and env.difficulties != []
    end

    test "raises for an unknown ROM name" do
      assert_raise ArgumentError, ~r/could not find ROM/, fn ->
        Alex.new("definitely_not_a_real_game")
      end
    end

    test "accepts emulator settings" do
      env = tetris_env(repeat_action_probability: 0.0, frame_skip: 4)
      assert %Env{} = env
    end
  end

  describe "step/2" do
    test "returns an updated env and info map" do
      env = tetris_env()
      {env, info} = Alex.step(env, :down)

      assert %Env{} = env

      assert Map.keys(info) |> Enum.sort() ==
               [
                 :episode_frame,
                 :episode_reward,
                 :frame,
                 :game_over?,
                 :lives,
                 :reward,
                 :truncated?
               ]

      assert info.frame > 0
      assert is_boolean(info.game_over?)
    end

    test "accepts integer actions too" do
      env = tetris_env()
      assert {%Env{}, _info} = Alex.step(env, 0)
    end

    test "accumulates episode reward and resets it on reset/1" do
      env = tetris_env()

      {env, _} =
        Enum.reduce(1..20, {env, nil}, fn _, {e, _} ->
          Alex.step(e, Enum.random(Alex.minimal_actions(e)))
        end)

      assert Alex.episode_reward(env) >= 0
      env = Alex.reset(env)
      assert Alex.episode_reward(env) == 0
    end

    test "raises on an invalid action" do
      env = tetris_env()

      assert_raise ArgumentError, ~r/invalid action/, fn ->
        Alex.step(env, :teleport)
      end
    end
  end

  describe "observations" do
    test "screen_rgb returns a correctly-sized binary with shape" do
      env = tetris_env()
      {rgb, shape, dtype} = Alex.Screen.rgb(env)

      assert shape == {210, 160, 3}
      assert dtype == :u8
      assert byte_size(rgb) == 210 * 160 * 3
    end

    test "screen_grayscale returns a correctly-sized binary" do
      env = tetris_env()
      {gray, shape, :u8} = Alex.Screen.grayscale(env)

      assert shape == {210, 160}
      assert byte_size(gray) == 210 * 160
    end

    test "ram returns 128 bytes" do
      env = tetris_env()
      assert byte_size(Alex.RAM.read(env)) == 128
    end
  end

  describe "snapshots" do
    test "save/restore rewinds the emulator" do
      env = tetris_env()
      snap = Alex.Snapshot.save(env)

      {env, _} =
        Enum.reduce(1..30, {env, nil}, fn _, {e, _} ->
          Alex.step(e, Enum.random(Alex.minimal_actions(e)))
        end)

      assert Alex.frame(env) > 0
      env = Alex.Snapshot.restore(env, snap)
      assert Alex.frame(env) == 0
    end

    test "serialize/deserialize round-trips" do
      env = tetris_env()
      snap = Alex.Snapshot.save(env, include_rng: true)

      bytes = Alex.Snapshot.serialize(snap)
      assert is_binary(bytes) and byte_size(bytes) > 0

      restored = Alex.Snapshot.deserialize(bytes)
      env = Alex.Snapshot.restore(env, restored)
      assert Alex.frame(env) == 0
    end
  end

  describe "episodes" do
    test "random play reaches game over" do
      env = tetris_env()

      {_env, info} =
        Enum.reduce_while(1..1_000_000, {env, nil}, fn _, {e, _} ->
          {e, info} = Alex.step(e, Enum.random(Alex.minimal_actions(e)))
          if info.game_over?, do: {:halt, {e, info}}, else: {:cont, {e, info}}
        end)

      assert info.game_over?
    end
  end
end
