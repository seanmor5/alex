defmodule Alex.State do
  alias Alex.Interface
  alias __MODULE__, as: State

  @moduledoc """
  Convenience functions for working with state.
  """

  @typedoc """
  Abstraction around ALE state.

  ## Fields

    - `:ref`: Reference to ALE state.
    - `:encoded`: Encoded version of ALE state.
    - `:length`: Length of encoded state.
  """
  @type t :: %__MODULE__{
    ref: reference(),
    encoded: Enum.t(),
    length: integer()
  }
  defstruct ref: nil, encoded: nil, length: 0

  @doc """
  Create a new state struct from provided state reference.

  Returns `%State{}`.

  # Parameters

    - `state`: Reference to state.
  """
  def new(%Interface{} = interface) do
    ale_ref = interface.ref

    with {:ok, state} <- Interface.clone_state(ale_ref),
         {:ok, encoded} <- Interface.encode_state(state),
         {:ok, length} <- Interface.encode_state_len(state) do
      {:ok, %State{ref: state, encoded: encoded, length: length}}
    else
      err -> raise err
    end
  end
end
