defmodule Alex.ActionTest do
  use ExUnit.Case, async: true
  doctest Alex.Action

  alias Alex.Action

  test "all/0 lists 18 actions in ALE integer order" do
    actions = Action.all()
    assert length(actions) == 18
    assert List.first(actions) == :noop
    assert Enum.at(actions, 1) == :fire
  end

  test "to_integer/1 and from_integer/1 round-trip" do
    for {name, _} <- Enum.with_index(Action.all()) do
      assert name |> Action.to_integer() |> Action.from_integer() == name
    end
  end

  test "to_integer/1 passes through valid integers" do
    assert Action.to_integer(10) == 10
  end

  test "raises on unknown names and values" do
    assert_raise ArgumentError, fn -> Action.to_integer(:nope) end
    assert_raise ArgumentError, fn -> Action.from_integer(99) end
  end

  test "valid?/1" do
    assert Action.valid?(:fire)
    assert Action.valid?(0)
    refute Action.valid?(:nope)
    refute Action.valid?(99)
    refute Action.valid?("fire")
  end
end
