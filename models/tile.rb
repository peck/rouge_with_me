class Tile
  include Comparable
  attr_accessor :dirty_neighbor, :icon
  attr_reader :x, :y, :maze, :walls, :passable_cost
  def initialize(x:, y:, maze:)
    @passable_cost = 1 << (1.size * 8 - 2) - 1
    @x = x
    @y = y
    @maze = maze
    @dirty_neighbor = true
    @icon = " "
  end

  def <=>(other)
    [x, y] <=> [other.x, other.y]
  end

  def to_s
    "#{@icon}"
  end

  def key_str
    "#{x}_#{y}"
  end

  def inspect
    "x: #{@x}, y: #{@y}"
  end

  def neighbors
    all_neighbors.values.compact
  end

  def cardinal_neighbors
    all_neighbors.values_at(:N, :E, :S, :W).compact
  end

  def all_neighbors
    if @dirty_neighbor
      @neighbors = maze.neighbors(self)
      @dirty_neighbor = false
    end
    @neighbors ||= maze.neighbors(self)
  end

  def distance(tile: tile)
    (manhattan_distance(tile: tile)*10).floor.to_i
  end


  def manhattan_distance(tile:)
    xdiff = @x - tile.x
    ydiff = @y - tile.y
    (xdiff.abs + ydiff.abs)
  end

  def euclid_distance(tile:)
    xdiff = @x - tile.x
    ydiff = @y - tile.y
    Math.sqrt(xdiff**2 + ydiff**2)
  end
end
