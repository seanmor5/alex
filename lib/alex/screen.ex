defmodule Alex.Screen do
  alias Alex.Interface
  alias __MODULE__, as: Screen

  @moduledoc """
  Convenience functions for working with the Screen.
  """

  @typedoc """
  Abstraction around ALE screen.

  ## Fields

    - `:data`: Screen data.
    - `:dim`: Tuple screen dimension.
    - `:rgb`: RGB Screen data.
    - `:grayscale`: Grayscale screen data.
  """
  @type t :: %__MODULE__{
    data: Enum.t(),
    dim: {integer(), integer()},
    rgb: Enum.t(),
    grayscale: Enum.t()
  }
  defstruct [:data, :dim, :rgb, :grayscale]

  @doc """
  Creates a new `Screen` struct.

  Returns `%Screen{}`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def new(%Interface{} = interface) do
    ale_ref = interface.ref

    with {:ok, screen} <- Interface.get_screen(ale_ref),
         {:ok, rgb} <- Interface.get_screen_rgb(ale_ref),
         {:ok, grayscale} <- Interface.get_screen_grayscale(ale_ref),
         {:ok, height} <- Interface.get_screen_height(ale_ref),
         {:ok, width} <- Interface.get_screen_width(ale_ref) do
      {:ok, %Screen{data: screen, dim: {width, height}, rgb: rgb, grayscale: grayscale}}
    else
      err -> raise err
    end
  end
end
