defmodule SegmentTree do
  defstruct(root: nil, low: nil, high: nil)

  require Vertex

  @doc """
  Example

  iex> SegmentTree.get_aggregation(SegmentTree.update(SegmentTree.new([1,2,3,4]) , 1, 10, &SegmentTree.sum_aggregation/3))
  18
  """
  def update(
        %SegmentTree{root: %Vertex{left: left, right: right}, low: low, high: high} = tree,
        index,
        new_value,
        aggregate_function
      ) do
    if low > index or high < index do
      tree
    else
      if low == high do
        %SegmentTree{root: %Vertex{value: new_value, left: nil, right: nil}, low: low, high: high}
      else
        left_update = update(left, index, new_value, aggregate_function)
        right_update = update(right, index, new_value, aggregate_function)

        %SegmentTree{
          root: %Vertex{
            value:
              aggregate_function.(
                nil,
                left_update,
                right_update
              ),
            left: left_update,
            right: right_update
          },
          low: low,
          high: high
        }
      end
    end
  end

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

  def get_aggregation(nil) do
    nil
  end

  def sum_aggregation(nil, %SegmentTree{} = left, %SegmentTree{} = right) do
    get_aggregation(left) + get_aggregation(right)
  end

  def sum_aggregation(value, nil, nil) do
    value
  end

  def sum_aggregation(nil, left, nil) do
    left
  end

  def sum_aggregation(nil, nil, right) do
    right
  end

  def sum_aggregation(nil, left, right) do
    left + right
  end

  def mul_aggregation(nil, %SegmentTree{} = left, %SegmentTree{} = right) do
    get_aggregation(left) * get_aggregation(right)
  end

  def mul_aggregation(value, nil, nil) do
    value
  end

  def mul_aggregation(nil, nil, right) do
    right
  end

  def mul_aggregation(nil, left, nil) do
    left
  end

  def mul_aggregation(nil, left, right) do
    left * right
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
