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

  @doc """
  Set interface to given state.

  Returns `{:ok, interface}`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def set_state(%Interface{} = interface, %State{} = state) do
    ale_ref = interface.ref

    with :ok <- Interface.restore_state(state.ref),
         {:ok, modes} <- Interface.get_available_modes(ale_ref),
         {:ok, difficulties} <- Interface.get_available_difficulties(ale_ref),
         {:ok, difficulty} <- Interface.get_difficulty(ale_ref),
         {:ok, legal_actions} <- Interface.get_legal_action_set(ale_ref),
         {:ok, min_actions} <- Interface.get_minimal_action_set(ale_ref),
         {:ok, lives} <- Interface.lives(ale_ref),
         {:ok, frame} <- Interface.get_frame_number(ale_ref),
         {:ok, episode_frame} <- Interface.get_episode_frame_number(ale_ref),
         {:ok, state} <- State.new(interface),
         {:ok, screen} <- Screen.new(interface) do
      {:ok,
       %Interface{
         interface
         | modes: modes,
           difficulties: difficulties,
           difficulty: difficulty,
           legal_actions: MapSet.new(legal_actions),
           minimal_actions: min_actions,
           lives: lives,
           frame: frame,
           episode_frame: episode_frame,
           state: state,
           screen: screen
       }}
    else
      err -> raise err
    end
  end
end
