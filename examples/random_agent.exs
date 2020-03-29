# Create new Alex interface
interface = Alex.new()

# Set Options
interface =
  interface
  |> Alex.set_option(:display_screen, true)
  |> Alex.set_option(:random_seed, 123)

# Load the ROM
tetris = Alex.load(interface, "priv/jamesbond.bin")

episode =
  fn game, episode ->
    if Alex.game_over?(game) do
      game
    else
      game = Alex.step(game, Enum.random(game.legal_actions))
      episode.(game, episode)
    end
  end

# Run the Game and Store Object
tetris = episode.(tetris, episode)

# Take a Screenshot of Final Screen
Alex.screenshot(tetris)

# Output Result
IO.write("\nEpisode ended with score: #{tetris.reward}\n")