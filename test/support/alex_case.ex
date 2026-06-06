defmodule Alex.Case do
  @moduledoc """
  Test helpers shared across the ALEx suite.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Alex.Case
    end
  end

  @doc """
  Path to the bundled `tetris` ROM fixture, resolved from `priv/roms`.
  """
  def tetris_rom do
    Path.join([:code.priv_dir(:alex), "roms", "tetris.bin"])
  end

  @doc """
  A freshly-loaded tetris environment with a fixed seed for determinism.
  """
  def tetris_env(opts \\ []) do
    Alex.new(tetris_rom(), Keyword.put_new(opts, :random_seed, 42))
  end
end
