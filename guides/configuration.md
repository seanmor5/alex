# Configuration

The ALE has a number of configuration options you can set to change the runtime experience.

## Initialization Options

When you first create your an Interface with `Alex.new/1`, you can add the following options:

    - `:display_screen`: `true` or `false` to display screen. Defaults to `false`.
    - `:random_seed`: `Integer` ALE random seed. Defaults to current time.
    - `:sound`: `true` or `false` to play sound. Defaults to `false`.

## Environment Options

Once you've loaded a ROM, you can set a number of environment options:

    - `:repeat_action_probability`: `Float` probability that agent will repeat action in next frame regardless of it's choice. Defaults to 0.
    - `:color_averaging`: `true` or `false` to enable color averaging. Defaults to `false`.
    - `:max_num_frames`: `Integer` maximum frames to run. Defaults to `0` or no max.
    - `:max_num_frames_per_episode`: maximum frames to run per episode. Defaults to `0` or no max.
    - `:frame_skip`: `Integer` frame skipping rate. Defaults to `1` or no skip.
    - `:difficulty`: `Integer` game difficulty. Defaults to `0`.
    - `:mode`: `Integer` game mode. Defaults to `0`.`

