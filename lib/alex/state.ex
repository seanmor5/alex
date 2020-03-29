defmodule Alex.State do
  alias Alex.Interface
  alias __MODULE__, as: State
  @moduledoc """
  Convenience functions for working with state.
  """

  defstruct ref: nil, encoded: nil, length: 0

  @doc """
  Create a new state struct from provided state reference.

  Returns `%State{}`.

  # Parameters

    - `state`: Reference to state.
  """
  def new(state) do
    with {:ok, encoded} <- Interface.encode_state(ale_ref),
         {:ok, length}  <- Interface.encode_state_len(ale_ref) do
          %State{ref: state, encoded: encoded, length: length}
    else
      raise err -> err
    end
  end

  @doc """
  Get the current encoded state.

  Returns `{:ok, encoding}`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def get_state(%Interface{} = interface) do
    ale_ref = interface.ref
    with {:ok, state}   <- Interface.clone_state(ale_ref) do
      {:ok, State.new(state)}
    end
    else
      err -> raise err
    end
  end

  @doc """
  Set interface to given state.

  Returns `{:ok, interface}`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def set_state(%Interface{} = interface, %State{} = state), do: :ok
end