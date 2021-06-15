defmodule Vertex do
  defstruct(value: nil, left: nil, right: nil)

  def new(value) do
    %Vertex{value: value}
  end
end
