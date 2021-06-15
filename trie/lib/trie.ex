defmodule Trie do
  defstruct(root: Vertex.new())

  def new(strings) do
    new(strings, %Trie{})
  end

  defp new([] = _strings, result) do
    result
  end

  defp new([h | t] = _strings, result) do
    new(t, append(result, h))
  end

  def append(nil, "") do
    %Trie{root: Vertex.new()}
  end

  def append(nil = _non_existing_trie, string) do
    append(%Trie{root: Vertex.new()}, string)
  end

  def append(%Trie{root: %Vertex{children: children}} = _trie, string) do
    first_letter = String.first(string)
    rest = String.slice(string, 1..String.length(string))
    updated_child = append(Map.get(children, first_letter, nil), rest)
    %Trie{root: %Vertex{children: Map.put(children, first_letter, updated_child)}}
  end
end
