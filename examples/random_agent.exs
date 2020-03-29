# Create new Alex interface
interface = Alex.new(display_screen: true, random_seed: 123)

# Load the ROM
interface = Alex.load(interface, "priv/tetris.bin")

# Legal Actions
legal_actions = interface.legal_actions

episode =
  fn total, episode ->
    if Alex.game_over?(interface) do
      total
    else
      {:ok, reward} = Alex.Interface.act(interface.ref, Enum.random(legal_actions))
      total = total + reward
      episode.(total, episode)
    end
  end

score = episode.(0, episode)

IO.write("\nEpisode ended with score: #{score}\n")