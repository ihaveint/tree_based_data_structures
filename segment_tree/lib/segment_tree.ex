defmodule SegmentTree do
  defstruct(root: nil, low: nil, high: nil)

  require Vertex

  @doc """
  Examples
    iex> SegmentTree.query(SegmentTree.new([1,2,3,4]), 0, 2)
    6

    iex> SegmentTree.query(SegmentTree.new([1,2,3,4]), 3, 3)
    4
  """
  def query(%SegmentTree{} = tree, l, h) do
    query(tree, l, h, &sum_aggregation/3)
  end

  @doc """
  Examples
    iex> SegmentTree.query(SegmentTree.new([1,2,3,4], &SegmentTree.mul_aggregation/3), 1, 2, &SegmentTree.mul_aggregation/3)
    6

    iex> SegmentTree.query(SegmentTree.new([1,2,3,4], &SegmentTree.mul_aggregation/3), 1, 3, &SegmentTree.mul_aggregation/3)
    24
  """
  def query(
        %SegmentTree{root: %Vertex{left: left, right: right}, low: low, high: high} = tree,
        l,
        h,
        aggregate_function
      ) do
    if l > high or h < low do
      aggregate_function.(nil, nil, nil)
    else
      if low >= l and high <= h do
        get_aggregation(tree)
      else
        aggregate_function.(
          nil,
          query(left, l, h, aggregate_function),
          query(right, l, h, aggregate_function)
        )
      end
    end
  end

  def get_aggregation(%SegmentTree{root: %Vertex{value: value}} = _segment_tree) do
    value
  end

  def sum_aggregation(nil, nil, nil) do
    0
  end

  def sum_aggregation(nil, %SegmentTree{} = left, %SegmentTree{} = right) do
    get_aggregation(left) + get_aggregation(right)
  end

  def sum_aggregation(nil, left, right) do
    left + right
  end

  def sum_aggregation(value, nil, nil) do
    value
  end

  def mul_aggregation(nil, nil, nil) do
    1
  end

  def mul_aggregation(nil, %SegmentTree{} = left, %SegmentTree{} = right) do
    get_aggregation(left) * get_aggregation(right)
  end

  def mul_aggregation(nil, left, right) do
    left * right
  end

  def mul_aggregation(value, nil, nil) do
    value
  end

  @doc """
  ## Example

      iex> SegmentTree.get_aggregation(SegmentTree.new([1,2,3,4]))
      10

  """
  def new(array) do
    new(array, 0, length(array) - 1, &sum_aggregation/3)
  end

  def new(array, aggregate_function) do
    new(array, 0, length(array) - 1, aggregate_function)
  end

  def new([leaf] = _array, low, high, aggregate_function) do
    %SegmentTree{
      root: Vertex.new(aggregate_function.(leaf, nil, nil)),
      low: low,
      high: high
    }
  end

  def new(array, low, high, aggregate_function) do
    n = length(array)
    array1 = Enum.slice(array, 0, div(n, 2))
    array2 = Enum.slice(array, div(n, 2), n)
    mid = low + length(array1) - 1
    left = SegmentTree.new(array1, low, mid, aggregate_function)
    right = SegmentTree.new(array2, mid + 1, high, aggregate_function)

    %SegmentTree{
      root: %Vertex{
        value: aggregate_function.(nil, left, right),
        left: left,
        right: right
      },
      low: low,
      high: high
    }
  end
end
