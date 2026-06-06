# A random agent playing a full episode.
#
# Run with a ROM name (resolved against your ROM directory):
#
#     mix run examples/random_agent.exs breakout
#
# or with an explicit path to a .bin file:
#
#     mix run examples/random_agent.exs priv/roms/tetris.bin

rom =
  case System.argv() do
    [rom | _] -> rom
    [] -> Path.join([:code.priv_dir(:alex), "roms", "tetris.bin"])
  end

env = Alex.new(rom, random_seed: 123)

IO.puts("Loaded #{Path.basename(env.rom)}")
IO.puts("Minimal actions: #{inspect(Alex.minimal_actions(env))}")

env =
  Enum.reduce_while(Stream.cycle([:play]), env, fn _, env ->
    {env, info} = Alex.step(env, Enum.random(Alex.minimal_actions(env)))

    if info.game_over? do
      {:halt, env}
    else
      {:cont, env}
    end
  end)

# Save the final frame next to this script.
:ok = Alex.Screen.save_png(env, "final_frame.png")

IO.puts("Episode ended after #{Alex.episode_frame(env)} frames")
IO.puts("Score (episode reward): #{Alex.episode_reward(env)}")
IO.puts("Saved final frame to final_frame.png")
