defmodule Alex.RAM do
  alias Alex.Interface
  alias __MODULE__, as: RAM
  @moduledoc """
  Convenience functions for working with ALE RAM.
  """

  @typedoc """
  Abstraction around ALE RAM.

  ## Fields

    - `:contents`: RAM contents.
    - `:size`: RAM size.
  """
  @type t :: %__MODULE__{
    contents: Enum.t(),
    size: integer()
  }
  defstruct [:contents, :size]

  @doc """
  Creates a new RAM struct.

  Returns `%Alex.RAM{}`.

  # Parameters

    - `interface`: `%Alex.Interface{}`.
  """
  def new(%Interface{} = interface) do
    ale_ref = interface.ref
    with {:ok, ram} <- Interface.get_ram(ale_ref),
         {:ok, ram_size} <- Interface.get_ram_size(ale_ref) do
           {:ok, %RAM{contents: ram, size: ram_size}}
    else
      err -> raise err
    end
  end
end