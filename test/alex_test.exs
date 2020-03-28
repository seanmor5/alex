defmodule AlexTest do
  alias Alex.Interface
  use ExUnit.Case
  doctest Alex

  describe "Alex" do
    test "new/0" do
      assert %Interface{} = Alex.new()
      assert %Interface{display_screen: true} = Alex.new([display_screen: true])
      assert %Interface{random_seed: 123} = Alex.new([random_seed: 123])
    end
  end
end
