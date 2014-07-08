class AsNode
  include Comparable
  attr_reader :tile, :g, :h, :parent

  def initialize(tile:, g:, h:, parent:)
    @tile = tile
    @g = g
    @h = h
    @parent = parent
  end

  def f
    g + h
  end

  def <=>(other)
    f <=> other.f
  end

  def ==(other)
    other.is_a?(AsNode) && tile == other.tile
  end

  def eql?(other)
    other.is_a?(AsNode) && tile == other.tile
  end

  def hash
    [tile].hash
  end

  def to_s
    "[#{tile.x}, #{tile.y}], cost: #{g+h}"
  end

  def point
    [tile.x, tile.y]
  end
end
