defmodule Alex.Screen do
  @moduledoc """
  Reading the current game screen.

  All functions return the pixel data as a **binary** together with its shape and
  dtype, so it can be fed directly into a tensor library (e.g.
  `Nx.from_binary/2` then `Nx.reshape/2`) without copying through a list.

  The standard Atari screen is 210×160. Pixels are row-major.
  """

  alias Alex.{Env, Native}

  @typedoc """
  `{binary, shape, dtype}` where `shape` matches the binary's row-major layout
  and `dtype` is always `:u8`.
  """
  @type observation :: {binary(), tuple(), :u8}

  @doc """
  Returns the screen as interleaved RGB.

  Shape is `{height, width, 3}`; the binary has `height * width * 3` bytes.
  """
  @spec rgb(Env.t()) :: observation()
  def rgb(%Env{ref: ref, screen_dims: {h, w}}) do
    {Native.screen_rgb(ref), {h, w, 3}, :u8}
  end

  @doc """
  Returns the screen as 8-bit grayscale.

  Shape is `{height, width}`; the binary has `height * width` bytes.
  """
  @spec grayscale(Env.t()) :: observation()
  def grayscale(%Env{ref: ref, screen_dims: {h, w}}) do
    {Native.screen_grayscale(ref), {h, w}, :u8}
  end

  @doc """
  Saves the current screen to `path` as a PNG.
  """
  @spec save_png(Env.t(), Path.t()) :: :ok
  def save_png(%Env{ref: ref}, path) do
    Native.save_screen_png(ref, path)
  end
end
