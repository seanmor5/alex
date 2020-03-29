defmodule Alex.State do
  alias Alex.Interface
  @moduledoc """
  Convenience functions for working with state.
  """

  @doc """
  Get the current encoded state.

  Returns `{:ok, encoding}`.

  # Parameters

    - `interface`: `%Interface{}`.
  """
  def get_state(%Interface{} = interface) do
    ale_ref = interface.ref
    with {:ok, state}   <- Interface.clone_state(ale_ref),
         {:ok, encoded} <- Interface.encode_state(state) do
           {:ok, encoded}
    else
      err -> raise err
    end
  end
end