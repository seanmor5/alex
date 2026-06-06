defmodule Alex.Action do
  @moduledoc """
  The Atari 2600 action set.

  ALE exposes 18 actions for the primary player. Each has a stable integer value
  (the value ALE itself uses) and a friendly atom name. The high-level `Alex` API
  accepts and returns the atom names; this module converts between the two and is
  the source of truth for the mapping.

      iex> Alex.Action.to_integer(:up_fire)
      10

      iex> Alex.Action.from_integer(10)
      :up_fire
  """

  # Ordered by ALE integer value (0..17). See ale/common/Constants.h.
  @actions [
    {:noop, 0},
    {:fire, 1},
    {:up, 2},
    {:right, 3},
    {:left, 4},
    {:down, 5},
    {:up_right, 6},
    {:up_left, 7},
    {:down_right, 8},
    {:down_left, 9},
    {:up_fire, 10},
    {:right_fire, 11},
    {:left_fire, 12},
    {:down_fire, 13},
    {:up_right_fire, 14},
    {:up_left_fire, 15},
    {:down_right_fire, 16},
    {:down_left_fire, 17}
  ]

  @to_integer Map.new(@actions)
  @from_integer Map.new(@actions, fn {name, value} -> {value, name} end)
  @names Enum.map(@actions, &elem(&1, 0))

  @type t :: unquote(Enum.reduce(@names, &quote(do: unquote(&1) | unquote(&2))))

  @doc """
  Returns every action name, ordered by ALE integer value.
  """
  @spec all() :: [t()]
  def all, do: @names

  @doc """
  Converts an action name (or an already-integer action) to its ALE integer.

  Raises `ArgumentError` for unknown actions.
  """
  @spec to_integer(t() | integer()) :: integer()
  def to_integer(action) when is_integer(action) do
    if Map.has_key?(@from_integer, action) do
      action
    else
      raise ArgumentError, "#{inspect(action)} is not a known action value"
    end
  end

  def to_integer(action) when is_atom(action) do
    case @to_integer do
      %{^action => value} ->
        value

      _ ->
        raise ArgumentError,
              "#{inspect(action)} is not a known action, expected one of #{inspect(@names)}"
    end
  end

  @doc """
  Converts an ALE integer to its action name.

  Raises `ArgumentError` for unknown values.
  """
  @spec from_integer(integer()) :: t()
  def from_integer(value) when is_integer(value) do
    case @from_integer do
      %{^value => name} -> name
      _ -> raise ArgumentError, "#{inspect(value)} is not a known action value"
    end
  end

  @doc false
  @spec valid?(term()) :: boolean()
  def valid?(action) when is_atom(action), do: Map.has_key?(@to_integer, action)
  def valid?(action) when is_integer(action), do: Map.has_key?(@from_integer, action)
  def valid?(_), do: false
end
