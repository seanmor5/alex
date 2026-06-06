defmodule Alex.RAM do
  @moduledoc """
  Reading the console's 128 bytes of RAM.

  RAM observations are useful for state-based agents and for inspecting
  game-specific memory locations.
  """

  alias Alex.{Env, Native}

  @doc """
  Returns the 128 bytes of console RAM as a binary.
  """
  @spec read(Env.t()) :: binary()
  def read(%Env{ref: ref}) do
    Native.get_ram(ref)
  end

  @doc """
  Returns the byte at the given RAM `index` (0..127).
  """
  @spec at(Env.t(), non_neg_integer()) :: byte()
  def at(%Env{} = env, index) when is_integer(index) and index >= 0 do
    :binary.at(read(env), index)
  end
end
